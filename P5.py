import numpy as np
from PIL import Image
def convert_to_p5(input_image_path, output_pgm_path, size):
    # Open and convert image to grayscale
    img = Image.open(input_image_path).convert("L")
    img = img.resize((size, size))  # Ensure image is the correct size

    # Convert the image to a numpy array
    image_data = np.array(img, dtype=np.uint8)

    # Save the image as P5 PGM format
    with open(output_pgm_path, "wb") as f:
        # Write the P5 header
        f.write(b"P5\n")
        f.write(f"{size} {size} \n".encode())  # Set the size to 400x400
        f.write(b"255\n")  # Max pixel value for PGM is usually 255
        # Write the pixel data
        f.write(image_data.tobytes())

    print(f"Image converted to P5 PGM format and saved as {output_pgm_path}")

# Example usage
size = 1024
input_image = f"{size}.png"  # Replace with your image path
output_image = r"C:\Users\User\OneDrive\Desktop\archProject\image1024.pgm"
convert_to_p5(input_image, output_image, size)
