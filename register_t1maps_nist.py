#!/usr/bin/python

import sys
import json
from pathlib import Path


def main():
    # First argument: Path to JSON config file
    # Second argument: Path to pooled NIST data

    # Parse function input
    args = sys.argv[1:]
    configFilename = args[0]
    inputFolder = args[1]

    # Load config file for datasets
    with open(configFilename) as json_file:
        data = json.load(json_file)

    # Loop across submitters (aka sites)
    for submitter in data.keys():
        for _, dataset in data[submitter]['datasets'].items():
            if dataset['dataType'] == 'Magnitude':
                file_mag = Path(dataset['imagePath']).parts[-1]
                file_mag = Path(inputFolder, file_mag)
                print("\nProcessing: {}".format(file_mag))
                # register file_mag to ref_mag
                # TODO
                # apply inverse transformation to ref_mask
                # TODO


if __name__ == "__main__":
    main()
