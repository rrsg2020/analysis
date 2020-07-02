#!/usr/bin/python

import os
import sys
import json
from pathlib import Path
import shutil
import subprocess
import argparse


# TODO: try registering with 3rd echo


SUFFIXMODIFHEADER = '_modifheader'


def add_suffix(fname, suffix):
    """
    Add suffix between end of file name and extension.

    :param fname: absolute or relative file name. Example: t2.nii
    :param suffix: suffix. Example: _mean
    :return: file name with suffix. Example: t2_mean.nii

    Examples:

    - add_suffix(t2.nii, _mean) -> t2_mean.nii
    - add_suffix(t2.nii.gz, a) -> t2a.nii.gz
    """
    def _splitext(fname):
        """
        Split a fname (folder/file + ext) into a folder/file and extension.

        Note: for .nii.gz the extension is understandably .nii.gz, not .gz
        (``os.path.splitext()`` would want to do the latter, hence the special case).
        """
        dir, filename = os.path.split(fname)
        for special_ext in ['.nii.gz', '.tar.gz']:
            if filename.endswith(special_ext):
                stem, ext = filename[:-len(special_ext)], special_ext
                return os.path.join(dir, stem), ext
        # If no special case, behaves like the regular splitext
        stem, ext = os.path.splitext(filename)
        return os.path.join(dir, stem), ext

    stem, ext = _splitext(fname)
    return os.path.join(stem + suffix + ext)


def run_subprocess(cmd):
    """
    Wrapper for subprocess.run() that enables to input cmd as a full string (easier for debugging).
    :param cmd:
    :return:
    """
    print("\nRunning:\n{}".format(cmd))
    subprocess.run(cmd.split(' '), stdout=subprocess.PIPE, text=True)


def extract_first_echo(fname_nii):
    """
    Split input nii file across the 4th dimension and return file name of the 1st volume. This would typically be used
    to split multi-echo data.
    :param fname_nii: str: file name of input 4D nifti file
    :return: fname_nii_1stecho: str: file name of 3D nifti file corresponding to the 1st volume
    """
    run_subprocess('fslsplit {} {} -t'.format(fname_nii, add_suffix(str(fname_nii), '_echo')))
    # Return file name of the first echo
    return add_suffix(str(fname_nii), '_echo0000')


def main():

    # initiate the parser
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", nargs=2, help="Json files corresponding to the raw (unprocessed) nifti files "
                                                      "and t1maps, respectively.")
    parser.add_argument("-p", "--path", nargs=2, help="Path to raw and t1maps folders, respectively.")

    # read arguments from the command line
    args = parser.parse_args()
    config_files = args.json
    input_folders = args.path

    # Load config file for datasets
    with open(config_files[0]) as json_file:
        config_raw = json.load(json_file)
    with open(config_files[1]) as json_file:
        config_t1map = json.load(json_file)

    # Get reference image
    # TODO
    file_mag_ref = Path(input_folders[0], '20200210_guillaumegilbert_muhc_NIST_Magnitude.nii.gz')
    file_mag_ref = extract_first_echo(file_mag_ref)

    # Loop across submitters (aka sites)
    for submitter in config_raw.keys():
        for _, dataset in config_raw[submitter]['datasets'].items():
            if dataset['dataType'] == 'Magnitude':
                file_mag = Path(dataset['imagePath']).parts[-1]
                file_mag = Path(input_folders[0], file_mag)
                print("\n---\nProcessing: {}".format(file_mag))
                # Extract first echo before copying header (to make sure src/dest dims are the same)
                file_mag_firstecho = extract_first_echo(file_mag)
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
                file_mag_src = add_suffix(file_mag_firstecho, SUFFIXMODIFHEADER)
                shutil.copy(file_mag_firstecho, file_mag_src)
                run_subprocess('fslcpgeom {} {} -d'.format(file_mag_ref, file_mag_src))
                # bring label to proper folder and update header
                # TODO: fetch label filename
                # file_label =
                shutil.copy(file_label, file_label_src)
                # TODO: registration
                # apply inverse transformation to ref_mask
                # TODO


if __name__ == "__main__":
    main()
