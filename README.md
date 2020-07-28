# Analysis

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/rrsg2020/analysis/master?filepath=generate_database.ipynb)

## Registering images

### Prerequesites

* [ANTs](https://github.com/ANTsX/ANTs) (tested with version 2.3.3.dev168-g29bdf)
* Python 3.7
* Clone this repository and install its requirements:
  ````bash
  git lone https://github.com/rrsg2020/analysis.git rrsg2020/analysis
  cd rrsg2020/analysis
  pip install -r requirements.txt
  ````

### Download datasets and pool into one folder


Run the commands: 
```bash
python make_pooled_datasets.py configs/3T_NIST_T1maps.json 3T_NIST_T1maps
python make_pooled_datasets.py configs/3T_NIST.json 3T_NIST
```

Note: Labels and a phantom mask are already included in the T1 map OSF dataset 


### Register datasets to the reference

Run the registration script:
```bash
python register_t1maps_nist.py -j configs/3T_NIST.json -p 3T_NIST_pooled/ 3T_NIST_T1maps_pooled/
```

Note: the registration script will download the reference mask (e.g. for the NIST phantom)
and will create labels for the initial affine transformation. 