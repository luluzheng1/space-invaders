#! /usr/bin/env python3

# Convert an image to an ASCII hex file which can be read in Verilog with memreadh
# Steven Bell <sbell@ece.tufts.edu>

# You'll need the pillow library to read images
# And Numpy to manipulate the image as a matrix
from PIL import Image
import numpy as np

outfile = open('you_win.hex', 'w')

# Open the input image and convert it to a Numpy array
# The input image should generally be a power of 2 in width/height
img = np.asarray(Image.open('Images/you_win.png'))

# Iterate through all the pixels
for row in range(img.shape[0]):
  for col in range(img.shape[1]):
    # Convert the pixel data (which is 8 bits for each of R/G/B) into our
    # format for the ROM.  This code just does a simple threshold: if the input
    # pixel is "bright", then make the output pixel (which we're representing
    # with 4 bits) all 1s.  Otherwise, make it all 0s.
    # This part will obviously vary depending on how you represent color.
    if sum(img[row][col][0:2]) > 250:
      pixel = 0x1
    else:
      pixel = 0x0
    # Write each pixel as a hex number separated by a space
    outfile.write('%x' % pixel)

  # Use a newline for each row, just so the output file is human-readable
  outfile.write('\n')

# All done!
outfile.close()

