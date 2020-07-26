#!/usr/bin/python

import wget
import zipfile
from pathlib import Path
import os
import sys
import json
import shutil

def make_pooled_dataset(configFilename=None, outputFolder=None):
    # First argument: Path to JSON config file
    # Second argument: Path to base saved directory

    if configFilename is None or outputFolder is None:
        # Parse function input
        args = sys.argv[1:]
        configFilename = args[0]
        outputFolder = args[1]


    # Load config file for datasets
    with open(configFilename) as json_file:
        data = json.load(json_file)

    # Download all datasets to one folder
    for submitter in data.keys():
        print(data[submitter]['OSF_link'])
        wget.download(data[submitter]['OSF_link'])

        for filename in os.listdir(str(Path(os.getcwd()))):
            if filename.endswith(".zip"):
                with zipfile.ZipFile(filename,"r") as zip_ref:
                    zip_ref.extractall(outputFolder)
                os.remove(filename)
            else:
                continue
        print('\n')

    
    # Pool nifti files into one directory
    rootdir = Path(os.getcwd())

    file_list = [f for f in rootdir.resolve().glob('**/*.nii*') if f.is_file()]

    newDir = outputFolder + '_pooled'
    os.mkdir(newDir)

    for file in file_list:
        shutil.copyfile(file, rootdir / newDir / file.name) 

if __name__ == "__main__":
    make_pooled_dataset()
