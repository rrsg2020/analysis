#!/bin/bash
#
# This script loops across T1maps images and register them to the reference
# image. This script needs to be called from within the T1map folder of the
# images to process. Example:
#   cd challenge_NIST/t1maps
#   ~/code/rrsg2020_analysis/register_t1maps_nist.sh
#
# IMPORTANT:
# - Before running this script, you must create labels as explained
#   in: image_labels.png. You can use NIFTI editors such as FSLeyes or ITKsnap
#   to do it.
# - The labels image should be called with suffix "labels". Example:
#   20200210_guillaumegilbert_muhc_NIST_Magnitude_t1map_labels.nii.gz
# - You must also create a mask on the reference image, as examplified in:
#   image_mask.png
#
# DEPENDENCIES:
# - ANTs (antsRegistration)
# - FSL (fslcpgeom)

# Uncomment for full verbose
set -x
set -v


# PARAMETERS
# ----------
# Choose reference image. Do NOT add the extension
FILEREF="20200210_guillaumegilbert_muhc_NIST_Magnitude_t1map"
# Extension for NIFTI file names
EXT="nii.gz"
# Suffix of images to register
SUFFIXT1="_t1map"
SUFFIXLABEL="_labels"
SUFFIXMASK="_mask"


# SCRIPT STARTS HERE
# ------------------
# Loop across images and register to the ref image
# Note: here we assume that all images to register have the suffix
FILES=`ls *${SUFFIXT1}.nii.gz`
for file in $FILES; do
	# Remove extension for easier parsing
  file=${file%???????}
	fileout=${file}_reg
	# Skip ref image (no need to register it to itself)
	if [ $file != $FILEREF ]; then
		# Some sites placed the phantom with a flip along z axis, or oriented the
		# FOV along another direction than the ref image, causing the labels to go
		# in the clockwise direction (whereas they are oriented anti-clockwise in
		# the ref image), causing the label-based transformation to fail. For this
		# reason, we need to copy header information from the ref image to the
		# moving image.
		# Note: I've also tried flipping the image and labels using PermuteFlipImageOrientationAxes
		# but for some reasons i do not understand, the flipping does not produce
		# the same qform between the output image and labels (even though the inputs
		# have the same qform...).
    cp $file.$EXT ${file}_modifheader.$EXT
    fslcpgeom $FILEREF.$EXT ${file}_modifheader.$EXT -d
    cp $file${SUFFIXLABEL}.$EXT ${file}_modifheader${SUFFIXLABEL}.$EXT
    fslcpgeom $FILEREF.$EXT ${file}_modifheader${SUFFIXLABEL}.$EXT -d
	  file=${file}_modifheader
		# Label-based registration
    antsLandmarkBasedTransformInitializer 2 $FILEREF$SUFFIXLABEL.$EXT $file$SUFFIXLABEL.$EXT affine $file.mat
		# Apply transformation (only for debugging purpose)
		antsApplyTransforms -d 2 -r $FILEREF.$EXT -i $file.$EXT -o ${file}_reg-labelbased.$EXT -t $file.mat
		# Affine registration
		antsRegistration -d 2 -r $file.mat -t Affine[0.1] -m CC[ $FILEREF.$EXT , $file.$EXT] -c 100x100x100 -s 0x0x0 -f 4x2x1 -x $FILEREF${SUFFIXMASK}.$EXT -o [$file_, $fileout.$EXT] -v
		# Convert to jpg for easy QC
		ConvertToJpg $file.$EXT $file.jpg
		ConvertToJpg $fileout.$EXT $fileout.jpg
	fi
done
# Also convert the reference image
ConvertToJpg $FILEREF.$EXT $FILEREF.jpg
ConvertToJpg $FILEREF.$EXT ${FILEREF}_reg.jpg
# show syntax to convert to gif
echo "Done! To convert to gif anim, you can use gifmaker (https://github.com/neuropoly/internal_tools/blob/master/python/gifmaker.py):"
echo "gifmaker -i *t1map_reg.jpg -o t1map_reg.gif"
