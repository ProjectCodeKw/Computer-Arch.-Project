#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <iostream>
#include <bitset>
#include <fstream>  // For std::ofstream
#include <string>   // For std::getline
#include <ctime>    // For clock()

void cpuLBP(unsigned char* Arr, unsigned char* ArrOut, int height, int width) {
	// CPU implementation for the LBP kernel ;D
	// we will skip the boundry pixels becuase they dont have 8 neighbors, start with index 1
    for (int i = 1; i < height - 1; i++) //iterate through the rows
    {
        for (int j = 1; j < width - 1; j++) //iterate throught the columns
        {
            unsigned char center_pixel = Arr[i * width + j]; // 1D access for 2D array
			int lbp = 0; // initialize LBP value
            
            // check the neighbors
            
            /*
            B0  B1  B2
            B7  C   B3
            B6  B5  B4
            */

            if (Arr[(i - 1) * width + (j - 1)] >= center_pixel)
                lbp += 1; //B0
            if (Arr[(i - 1) * width + j] >= center_pixel)
                lbp += 2; //B1
			if (Arr[(i - 1) * width + (j + 1)] >= center_pixel)
				lbp += 4; //B2
			if (Arr[i * width + (j + 1)] >= center_pixel)
				lbp += 8; //B3
			if (Arr[(i + 1) * width + (j + 1)] >= center_pixel)
				lbp += 16; //B4
			if (Arr[(i + 1) * width + j] >= center_pixel)
				lbp += 32; //B5
			if (Arr[(i + 1) * width + (j - 1)] >= center_pixel)
				lbp += 64; //B6
			if (Arr[i * width + (j - 1)] >= center_pixel)
				lbp += 128; //B7

			// convert the LBP value to binary (8-bits) byte
            unsigned char binary_lbp = static_cast<unsigned char>(lbp);

			ArrOut[i * width + j] = lbp; // store the decimal LBP value in the output array

        }
    }

}


// Function to read PGM (P5 binary) image
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

    file >> *width >> *height;  // Read width and height
    int maxVal;
    file >> maxVal;  // Maximum pixel value, typically 255
    file.ignore();  // Ignore the newline after the header

    *image = new unsigned char[*width * *height];  // Allocate memory for image data
    file.read(reinterpret_cast<char*>(*image), *width * *height);  // Read pixel data
    file.close();
    return true;
}

// Function to write output PGM (binary) image
void writePGM(const std::string& filename, unsigned char* image, int height, int width) {
    std::ofstream file(filename, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Error opening file!" << std::endl;
        return;
    }

    file << "P5\n";  // Magic number for PGM
    file << width << " " << height << "\n";
    file << "255\n";  // Max color value
    file.write(reinterpret_cast<char*>(image), width * height);  // Write pixel data
    file.close();
}


int main() {
    std::string filePath = "C:/Users/User/OneDrive/Desktop/archProject/image1024.pgm";  // P5 image file path after greyscale
    std::string outputPath = "C:/Users/User/OneDrive/Desktop/archProject/output1024.pgm";  // output file path

    // Read PGM file
    unsigned char* image = nullptr;
    int width, height;
    if (!readPGM(filePath, &image, &height, &width)) {
        return 1;
    }

    // Allocate memory for the output image
    unsigned char* outImage = (unsigned char*)malloc(width * height);

    // Measure CPU time for LBP processing
    clock_t start = clock();  // Start measuring time

    // Apply LBP processing
    cpuLBP(image, outImage, height, width);

    clock_t end = clock();    // End measuring time
    double duration = double(end - start) * 1000.0 / CLOCKS_PER_SEC;  // Calculate the duration in seconds
    std::cout << "CPU LBP processing time: " << duration << " ms\n";

    // Write the output image
    writePGM(outputPath, outImage, height, width);

    // Free memory
    free(image);
    free(outImage);

    std::cout << "LBP processing done. Output saved to " << outputPath << "\n";
    return 0;
}

