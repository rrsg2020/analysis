# Analysis

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/rrsg2020/analysis/master?filepath=generate_database.ipynb)

## Registering images

### Prerequesites

* [ANTs](https://github.com/ANTsX/ANTs)
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
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

Note: you can specify which reference image (aka target) to choose for co-registering all the sites by editing the 
`configs/.json` file and adding the field `"reference": true`. Example:

```xml
    "guillaumegilbert_muhc_NIST":{
        "OSF_link": "https://osf.io/qnhjt/download/",
        "datasets":{
            "magnitude": {
                "dataType": "Magnitude",
                "imagePath": "20200210_guillaumegilbert_muhc_NIST/20200210_guillaumegilbert_muhc_NIST_Magnitude.nii.gz",
                "reference": true
            },
```
