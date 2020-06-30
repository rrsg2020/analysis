# Analysis

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/rrsg2020/analysis/master)

## Registering images

### Prerequesites

* [ANTs](https://github.com/ANTsX/ANTs)
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
* Clone this repository and install its requirements:
  ````bash
  git lone https://github.com/rrsg2020/analysis.git rrsg2020/analysis
  cd rrsg2020/analysis
  pip install -r requirements.txt
  ````

### Download datasets and pool into one folder


Run the commands: 
```bash
python make_pooled_datasets.py configs/3T_NIST_t1maps.json 3T_NIST_t1maps
python make_pooled_datasets.py configs/3T_NIST.json 3T_NIST
```

Note: Labels and a phantom mask are already included in the T1 map OSF dataset 


### Register datasets to the reference

Run the registration script:
```bash
python register_t1maps_nist.py configs/3T_NIST.json 3T_NIST
```
