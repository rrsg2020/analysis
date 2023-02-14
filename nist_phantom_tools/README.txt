
NIST phantom registration toolbox
=================================


register_phantom2d.m - phantom registration via correlation with existing mask
roi_centers_ref.m - T1 and T2 array reference masks for the NIST MRI phantom

register_phantom2d_dr.m - test driver for register_phantom2d.m


DICOM utilities
---------------

read_sqmr_ir.m - read DICOM file (IR data)


Image masks and correlation analysis tools
------------------------------------------

circle.m - circle of of size n and radii [rmin,rmax], located at (cx,cy)
cmask.m - circular mask (disk) of size n and radius r0, located at (cx,cy)
conv2fft.m - convolution in R^2 via FFT
image_match2d.m - correlation analysis (rotation and shift) of two images
lsqcircle.m - fit circle to data via linearized least squares
edge2d.m - rough edge detection scheme in R^2


Utility functions
-----------------

is_octave.m - check if octave is present and running
rowcol.m - find row and column indices of nonzero entries in a matrix

