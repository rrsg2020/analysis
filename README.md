# Analysis

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/rrsg2020/analysis/master)

## Registering images

### Prerequesites

* [ANTs](https://github.com/ANTsX/ANTs)
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
* This repository's requirements
  * Install with `pip install -r requirements.txt `

### Download datasets and pool into one folder

Labels and a phantom mask are already included in the T1 map OSF dataset 

* Run the command `python make_pooled_datasets.py configs/3T_NIST_t1maps.json 3T_NIST_t1maps`

### Register datasets to the reference

* Open the pooled dataset folder: `cd 3T_NIST_t1maps_pooled`
* Run the registration pipeline: `../register_t1maps_nist.sh`

