#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <cstdio>
#include <fstream>
#include <string>
#include <iostream>


#define WIDTH 32 // same as num of thread

using namespace std;

// device code - kernel code
__global__ void greyscaleToLbpConversion(unsigned char* in, unsigned char* out, int w, int h)
{


	// Calculate global row and column indices based on the block and thread indices
	int bx = blockIdx.x;
	int by = blockIdx.y;
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	int row = by * WIDTH + ty;
	int col = bx * WIDTH + tx;

	// decleration for LBP vars
	int LBP[8];
	int LBPValue = 0;
	int lbp_i = 0;


	if (row < h && col < w ) {
			unsigned char center_pixel = in[row * w + col]; // 1D access for 2D array

			for (int i = -1; i <= 1; i++) {
				for (int j = -1; j <= 1; j++) {
					if (row + i >= 0 && row + i < h && col + j >= 0 && col + j < w) {
						// check if nighbor pixel is center 
						if ((i == 0 && j == 0))
							continue;
				
						// check neighbors with center
						if (in[(i + row) * w + (j + col)] >= center_pixel) 
							LBP[lbp_i] = 1; // neighbor > center -> LBP = 1
						else if (in[(i + row) * w + (j + col)] <= center_pixel) 
							LBP[lbp_i] = 0; // neighbor < center -> LBP = 0
						
						// increment LBP index
						lbp_i++;
					}// extra checking of boundry 
			}// inner col loop
		}// outer row loop
	}// if boundry

	// convert LBP value to binary
	LBPValue = LBP[0] * (128) + LBP[1] * (64) + LBP[2] * (32)
		+ LBP[3] * (16) + LBP[4] * (8) + LBP[5] * (4) + LBP[6] * (2)
		+ LBP[7] * (1);

	// store the decimal LBP value in output array
	out[row * w + col] = LBPValue; 
}// device code - kernel code


bool readPGM(const std::string& filename, unsigned char** image, int* height, int* width) {
	std::ifstream file(filename, std::ios::binary);
	if (!file.is_open()) {
		std::cerr << "Error opening file!" << std::endl;
		return false;
	}

	std::string magic;
	std::getline(file, magic);  // Read the magic number (P5)
	if (magic != "P5") {
		std::cerr << "Not a valid P5 PGM file!" << std::endl;
		return false;
	}

	file >> *width >> *height;
	int maxVal;
	file >> maxVal;
	file.ignore();

	*image = new unsigned char[*width * *height];
	file.read(reinterpret_cast<char*>(*image), *width * *height);
	file.close();
	return true;
}

void writePGM(const std::string& filename, unsigned char* image, int height, int width) {
	std::ofstream file(filename, std::ios::binary);
	if (!file.is_open()) {
		std::cerr << "Error opening file!" << std::endl;
		return;
	}

	file << "P5\n" << width << " " << height << "\n255\n";
	file.write(reinterpret_cast<char*>(image), width * height);
	file.close();
}


int main()
{
	std::string inputPath = "C:/Users/User/OneDrive/Desktop/archProject/image128.pgm";  // P5 image file path after greyscale
	std::string outputPath = "C:/Users/User/OneDrive/Desktop/archProject/outputGPU-128.pgm";  // output file path

	unsigned char* pic_in = nullptr; // pointer in host (in is gray)
	unsigned char* pic_out = nullptr; // pointer in host (out is LBP)
	unsigned char* d_pic_in = nullptr; // pointer of device (in is gray)
	unsigned char* d_pic_out = nullptr; // pointer of device (out is LBP)
	int width, height;
	int grey_size; // pixels in gray scale is 1 element

	// Read PGM file
	if (!readPGM(inputPath, &pic_in, &height, &width)) {
		return 1;
	}

	grey_size = width * height * sizeof(unsigned char);

	// allocate memory for device arrays
	cudaMalloc((void**)&d_pic_in, grey_size);
	cudaMalloc((void**)&d_pic_out, grey_size);

	// creating CUDA events (timer to see how much time from gray to LBP)
	cudaEvent_t start, stop;
	cudaEventCreate(&start); // create (& is address)
	cudaEventCreate(&stop);

	// copy host array to device (gray image)
	cudaMemcpy(d_pic_in, pic_in, grey_size, cudaMemcpyHostToDevice);

	// Initialize thread block and kernel grid dimensions
	int threads = 32; // given, size of one block
	int blocksX = ceil(width * 1.0 / WIDTH); //threads
	int blocksY = ceil(height * 1.0 / WIDTH); //threads

	dim3 BlockSize(WIDTH, WIDTH, 1); // 2D block
	dim3 GridSize(blocksX, blocksY, 1); // 2D thread

	// place start event into the default stream (timer is started ( to know how to compare CPU VS GPU))
	cudaEventRecord(start);

	// kernel call (pointers of device)
	greyscaleToLbpConversion << <GridSize, BlockSize >> > (d_pic_in, d_pic_out, width, height);

	// place stop event into the default stream
	cudaEventRecord(stop);

	// block CPU execution until the specified event is recorded
	cudaEventSynchronize(stop);

	float milliseconds = 0;
	// returns in the first argument the number of milliseconds time elapsed between the recording start and stop
	cudaEventElapsedTime(&milliseconds, start, stop);

	printf("GPU time is %.3f milliseconds\n", milliseconds);

	// allocate host memory for the output image
	pic_out = (unsigned char*)malloc(grey_size);

	// copy result from device to host
	cudaMemcpy(pic_out, d_pic_out, grey_size, cudaMemcpyDeviceToHost);

	// wait for device to complete all tasks
	cudaDeviceSynchronize();

	// Write the output image
	writePGM(outputPath, pic_out, height, width);

	// free
	cudaFree(d_pic_in);
	cudaFree(d_pic_out);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	free(pic_in);
	free(pic_out);

	std::cout << "LBP processing done on GPU. Output saved to " << outputPath << "\n";

	return 0;
}