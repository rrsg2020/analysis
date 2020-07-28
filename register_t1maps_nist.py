#!/usr/bin/python

import os
import sys
import json
from pathlib import Path
import shutil
import subprocess
import argparse
import glob
import datetime
import nibabel
import numpy as np
from PIL import Image, ImageFont, ImageDraw
import wget
import zipfile

from gifmaker.gifmaker import creategif


# TODO: add verbose mode
# TODO: make it possible to apply transformations to a specific echo (for easier visual QC)

SUFFIXMODIFHEADER = '_modifheader'
SUFFIXLABEL = '_T1map_labels'
NUM_ECHO = 2  # index of echo to use for registration


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


def copy_header(fname_src, fname_ref):
    """
    Copy affine matrix from fname_ref to fname_src. Do _not_ copy image header (which includes pix dimensions).
    :param fname_src:
    :param fname_ref:
    :return: fname_out
    """
    nii_src = nibabel.load(fname_src)
    nii_ref = nibabel.load(fname_ref)
    nii_src_in_ref = nibabel.Nifti1Image(nii_src.get_fdata(), nii_ref.affine, nii_src.header)
    fname_out = add_suffix(fname_src, SUFFIXMODIFHEADER)
    nibabel.save(nii_src_in_ref, fname_out)
    return fname_out


def create_labels(fname_ref):
    """
    Create labels on ref image and save as nifti file
    See label definition: https://github.com/rrsg2020/analysis/pull/2#issue-427450135
    :param fname_ref: reference image to create labels from (e.g. NIST phantom mask)
    :return: fname_label_ref
    """
    # Get reference image
    nii_ref = nibabel.load(fname_ref)
    data_ref_label = np.zeros_like(nii_ref.get_fdata())
    coord_labels = {
        1: (39, 77),
        2: (95, 154),
        3: (151, 77),
    }
    for value, coord in coord_labels.items():
        # Here, instead of creating single-point label, we create 3x3 labels. More details here:
        #  https://github.com/rrsg2020/analysis/issues/1#issuecomment-664495177
        data_ref_label[coord[0]-1: coord[0]+2, coord[1]-1: coord[1]+2] = value
    nii_label_ref = nibabel.Nifti1Image(data_ref_label, nii_ref.affine, nii_ref.header.copy())
    fname_label_ref = add_suffix(fname_ref, '_labels')
    nibabel.save(nii_label_ref, fname_label_ref)
    return fname_label_ref


def download_roi(url='https://osf.io/abfmg/download', folder_out='roi'):
    """
    Download ROIs from the internet and extract archive.
    :param url:
    :param folder_out:
    :return: output folder of extracted ROIs
    """
    # TODO: do this download outside of this CLI (ie should be part of another "install required data" CLI)
    print("\nDownloading ROIs...")
    fname_roi = wget.download(url)
    with zipfile.ZipFile(fname_roi, 'r') as zip_ref:
        zip_ref.extractall(folder_out)
    os.remove(fname_roi)
    return os.path.abspath(folder_out)


def extract_volume(fname_nii, ivol=0):
    """
    Split input nii file across the 4th dimension and return file name of the 1st volume. This would typically be used
    to split multi-echo data.
    :param fname_nii: str: file name of input 4D nifti file
    :param ivol: uint: Index of volume to extract
    :return: fname_nii_1stecho: str: file name of 3D nifti file corresponding to the 1st volume
    """
    nii = nibabel.load(fname_nii)
    if not nii.ndim == 4:
        raise ValueError("Input file is not 4d: {}".format(fname_nii))

    nii_3d = nibabel.Nifti1Image(nii.get_fdata()[:, :, :, ivol], nii.affine)
    fname_out = add_suffix(fname_nii, '_echo{}'.format(ivol))
    nibabel.save(nii_3d, fname_out)
    return fname_out


def run_subprocess(cmd):
    """
    Wrapper for subprocess.run() that enables to input cmd as a full string (easier for debugging).
    :param cmd:
    :return:
    """
    print("{}".format(cmd))
    subprocess.run(cmd.split(' '), stdout=subprocess.PIPE, text=True)


def main():

    # initiate the parser
    parser = argparse.ArgumentParser()
    parser.add_argument("-j", "--json", nargs=1, help="Json file corresponding to the raw (unprocessed) nifti files.")
    parser.add_argument("-p", "--path", nargs=2, help="Path to raw and t1maps folders, respectively.")

    # read arguments from the command line
    args = parser.parse_args()
    # show help if not enough arguments
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    config_files = args.json
    input_folders = args.path

    # Load config file for datasets
    with open(config_files[0]) as json_file:
        config_json = json.load(json_file)

    # Download ROIs
    path_roi = download_roi()

    # Create labels on the reference image
    fname_ref = Path(path_roi, 'T1_ROI_ones_192x192.nii')
    fname_label_ref = create_labels(fname_ref)

    # Loop across submitters (aka sites)
    for submitter in config_json.keys():
        for _, dataset in config_json[submitter]['datasets'].items():
            if dataset['dataType'] == 'Magnitude':
                file_mag = Path(dataset['imagePath']).parts[-1]
                fname_mag = Path(input_folders[0], file_mag)
                print("\n---\nProcessing: {}".format(fname_mag))
                # Extract specific echo before copying header (to make sure src/dest dims are the same)
                if '14point' in str(fname_mag):
                    # Edge case for the only acquisition that wasn't acquired with 4 inversion times.
                    # Echo value is for the phantom background signal null of the 14 point acquisition.
                    ECHO = 10
                    fname_mag_echo = extract_volume(fname_mag, ECHO)
                else:
                    fname_mag_echo = extract_volume(fname_mag, NUM_ECHO)
                # Some sites placed the phantom with a flip along z axis, or oriented the
                # FOV along another direction than the ref image, causing the labels to go
                # in the clockwise direction (whereas they are oriented anti-clockwise in
                # the ref image), causing the label-based transformation to fail. For this
                # reason, we need to copy header information from the ref image to the
                # moving image.
                fname_mag_src = copy_header(fname_mag_echo, fname_ref)
                # Here: assuming that T1maps have the same prefix as the file under 3T_NIST
                fname_label_src = Path(input_folders[1], add_suffix(file_mag, SUFFIXLABEL))
                if os.path.exists(fname_label_src):
                    fname_label = copy_header(fname_label_src, fname_label_ref)
                    # Label-based registration
                    fname_affine = Path(input_folders[0], str(file_mag).replace('Magnitude.nii.gz', 'Magnitude_affine-label.mat'))
                    run_subprocess('antsLandmarkBasedTransformInitializer 2 {} {} affine {}'.format(
                        fname_label_ref, fname_label, fname_affine))
                    # Apply transformation (only for debugging purpose)
                    run_subprocess('antsApplyTransforms -d 2 -r {} -i {} -o {} -t {}'.format(
                        fname_ref, fname_mag_src, add_suffix(fname_mag_src, '_reg-labelbased'), fname_affine))
                    # Affine registration
                    fname_mag_src_reg = add_suffix(fname_mag_src, '_reg')
                    run_subprocess('antsRegistration -d 2 -r {} -t Affine[0.1] -m CC[ {} , {} ] -c 100x100x100 -s 0x0x0 -f 4x2x1 -t BSplineSyN[0.5, 3] -m CC[ {} , {} ] -c 50x50x10 -s 0x0x0 -f 4x2x1 -o [ {} , {} ] -v'.format(
                        fname_affine, fname_ref, fname_mag_src, fname_ref, fname_mag_src, fname_mag_src.replace('.nii.gz', '_'), fname_mag_src_reg))
                    # apply inverse transformation to ref_mask
                    # TODO
                    # Convert to jpg for easy QC
                    fname_jpg = fname_mag_src_reg.replace('nii.gz', 'jpg')
                    run_subprocess('ConvertToJpg {} {}'.format(fname_mag_src_reg, fname_jpg))
                    # Add name of scan in the image
                    img = Image.open(fname_jpg)
                    draw = ImageDraw.Draw(img)
                    draw.text((0, 0), file_mag, fill=255)
                    img.save(fname_jpg)
                else:
                    print("Label does not exist. Skipping this image.")
    # Also convert the reference image
    fname_ref_jpg = fname_ref.as_posix().rstrip('.nii.gz').rstrip('.nii')+'.jpg'
    run_subprocess('ConvertToJpg {} {}'.format(fname_ref, fname_ref_jpg))
    # Create gif
    file_gif = 'results_reg_{}.gif'.format(datetime.datetime.now().strftime("%Y%m%d%H%M%S"))
    creategif([fname_ref_jpg]+glob.glob(os.path.join(input_folders[0], '*echo*_reg.jpg')), file_gif, duration=0.3)
    print("\nFinished! \n--> {}".format(file_gif))


if __name__ == "__main__":
    main()
