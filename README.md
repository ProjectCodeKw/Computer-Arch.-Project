# Local Binary Pattern (LBP) in CUDA C

This project implements the Local Binary Pattern (LBP) algorithm using CUDA C for parallel processing on NVIDIA GPUs. LBP is a simple yet effective texture operator that labels the pixels of an image by thresholding the neighborhood of each pixel and considering the result as a binary number.

## Running Instructions

1.  **Default Images:** The project is configured to run with three default grayscale PGM images: `image512.pgm`, `image128.pgm`, and `image1024.pgm`. These images should be present in the same directory as the CUDA project.

2.  **Using Custom Images:** If you wish to use your own RGB images, you will need to convert them to grayscale PGM format with a specific size using the provided Python script `P5.py`.

    * **Prerequisites:** Ensure you have Python installed on your system. You will also need to install the Pillow and Pandas libraries.

    * **Installation:**
        * **macOS:** Open your terminal and run:
            ```bash
            pip install Pillow pandas
            ```
        * **Windows:** Open your Command Prompt or PowerShell and run:
            ```bash
            pip install Pillow pandas
            ```

    * **Image Conversion:** modify the variables inside the `P5.py` script to point to your image path and select the size of the image (square images only). 
      

3.  **CUDA Kernel Selection and Project Setup:**

    * Open your Visual Studio and create a new CUDA project.
    * Choose the specific LBP kernel implementation you want to run (e.g., a basic LBP, a uniform LBP, etc.) and copy its CUDA C code (`.cu` file) into your Visual Studio CUDA project.
    * Replace the default `kernel.cu` content (or whatever the default CUDA file is named) with the code of your chosen LBP kernel.

4.  **Modifying Image Paths in `main()`:**

    * Locate the `main()` function in your CUDA C code.
    * Find the variables that store the paths to the input images (e.g., `const char* inputImagePath = "image512.pgm";`).
    * **If using default images:** Ensure the paths correctly point to `image512.pgm`, `image128.pgm`, or `image1024.pgm` (or whichever default image you intend to use).
    * **If using custom converted images:** Update the `inputImagePath` variable with the **correct and absolute path** to your converted PGM image. **Important:** Make sure to use forward slashes `/` in the path and ensure there are no spaces in the path. For example:
        ```c++
        const char* inputImagePath = "C:/Users/YourName/Pictures/converted_image.pgm";
        ```

5.  **Modifying Output Path:**

    * Find the variable that specifies the output path for the processed LBP image (e.g., `const char* outputPath = "lbp_output.pgm";`).
    * Modify this `outputPath` variable to the desired location and filename for the resulting LBP image in PGM format. Ensure you use forward slashes `/` and no spaces in the path, similar to the input path. For example:
        ```c++
        const char* outputPath = "D:/Results/lbp_processed.pgm";
        ```

6.  **Build and Run:**

    * Save all the changes in your Visual Studio project.
    * Build the CUDA project (typically by going to "Build" -> "Build Solution").
    * Run the executable **without debugging** (typically by pressing Ctrl + F5 or going to "Debug" -> "Start Without Debugging").

7.  **Output and Verification:**

    * After the program execution, you should see the histogram array and the execution time printed in the Visual Studio output window.
    * The processed LBP image will be saved in the location specified by the `outputPath` variable in PGM format.
    * To view the generated PGM image, you can use an online Netpbm viewer such as [https://paulcuth.me.uk/projects/netpbm-viewer/](https://paulcuth.me.uk/projects/netpbm-viewer/). Simply upload the generated `.pgm` file to this website to visualize the LBP texture.

That's all you need to run the LBP project!
