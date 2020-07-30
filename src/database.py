from pathlib import Path
import pandas as pd
import json
import nibabel as nib
import numpy as np

def create_database(configFile, data_folder_name):

    columns = [
    'id',
    'OSF dataset', 'OSF link', 'NIFTI filename', 'Data type',
    'contact',
    'site name', 'MRI vendor', 'MRI version', 'MRI field',
    'sample type',
    'phantom version', 'phantom serial number', 'phantom temperature',
    'age', 'sex',
    'sequence name', 'sequence type', 'matrix size', 'resolution', 'dimension', 'TR', 'echo time', 'TI', 'bandwidth',
    'T1 - genu (WM)', 'T1 - splenium (WM)', 'T1 - deep GM', 'T1 - cortical GM',
    'T1 - NIST sphere 1', 'T1 - NIST sphere 2', 'T1 - NIST sphere 3', 'T1 - NIST sphere 4', 'T1 - NIST sphere 5', 'T1 - NIST sphere 6', 'T1 - NIST sphere 7', 'T1 - NIST sphere 8', 'T1 - NIST sphere 9', 'T1 - NIST sphere 10', 'T1 - NIST sphere 11', 'T1 - NIST sphere 12', 'T1 - NIST sphere 13', 'T1 - NIST sphere 14'
    ]

    df = pd.DataFrame(columns=columns)
    df = df.set_index('id')
    
    df = parse_dataset_json(df, configFile, data_folder_name)
    
    return df

def parse_dataset_json(df, configFile, data_folder_name):

    id = 1
    subid = 1

    with open(configFile) as json_file:
        configJson = json.load(json_file)

    for dataset_name in configJson:
        db_id = id+subid*0.001
        for key1 in configJson[dataset_name]:
            if key1 == 'datasets':
                for key2 in configJson[dataset_name][key1]:
                    db_id = id+subid*0.001
                    subid = subid+1

                    dataset_series = {
                        'OSF dataset': dataset_name,
                        'OSF link': configJson[dataset_name]['OSF_link'],
                        'NIFTI filename': configJson[dataset_name]['datasets'][key2]['imagePath'],
                        'Data type': configJson[dataset_name]['datasets'][key2]['dataType']
                    }
                    
                    t1File = configJson[dataset_name]['datasets'][key2]['imagePath']
                    t1JsonFile = data_folder_name / Path(t1File[:-7] + '.json')
                    
                    with open(t1JsonFile) as json_file:
                        t1Json = json.load(json_file)

                    dataset_series = parse_t1_json(dataset_series, t1Json)
                    dataset_series = parse_rois(dataset_series, t1File, data_folder_name, t1Json['sample']['type'])
                    
                    df = df.append(pd.Series(dataset_series, index = df.columns, name = db_id))
        # Increment dataset ID counter
        id = id + 1
    
        # Reset subdataset ID counter
        subid = 1
    return df

def parse_t1_json(dataset_series, t1Json):
    dataset_series.update({
        'contact': t1Json['submitter']['contact'],
    })

    dataset_series.update({
        'site name': t1Json['site']['name'],
        'MRI vendor': t1Json['site']['manufacturer'],
        'MRI version': t1Json['site']['version'],
        'MRI field': t1Json['site']['field'],
    })
    
    if 'temperature' in t1Json['sample']:
        temp = t1Json['sample']['temperature']
    else:
        temp = None
    
    if 'NIST' in t1Json['sample']['type']:
        dataset_series.update({
            'sample type': t1Json['sample']['type'],
            'phantom version': t1Json['sample']['version'],
            'phantom serial number': t1Json['sample']['serial_number'],
            'phantom temperature': temp,
        })
        dataset_series.update({
            'age': None,
            'sex': None,
        })
    else:
        dataset_series.update({
            'sample type': 'Human',
            'age': t1Json['sample']['age'],
            'sex': t1Json['sample']['sex'],
        })
        dataset_series.update({
            'sample type': None,
            'phantom version': None,
            'phantom serial number': None,
            'phantom temperature': None,
        })


    if 'bandwidth' in t1Json['sequence']:
        bandwidth = t1Json['sequence']['bandwidth']
    else:
        bandwidth = None

    dataset_series.update({
        'sequence name': t1Json['sequence']['name'],
        'sequence type': t1Json['sequence']['type'],
        'matrix size': t1Json['sequence']['matrix_size'],
        'resolution': t1Json['sequence']['resolution'],
        'dimension': t1Json['sequence']['dimension'],
        'TR': t1Json['sequence']['repetition_time'],
        'echo time': t1Json['sequence']['echo_time'],
        'TI': t1Json['sequence']['inversion_times'],    
        'bandwidth': bandwidth,        
    })
    return dataset_series

def parse_rois(dataset_series, t1File, data_folder_name, sample_type):
    
    t1Path = Path(data_folder_name) / t1File
    t1 = nib.load(t1Path)
    t1_data = t1.get_fdata()
    
    if 'NIST' in sample_type:
        roi_data = None
    else:
        if 't1map' in str(t1File):
            roiFile = str(t1File)
            roiFile = roiFile.replace('t1map', 'rois')
        else:
            roiFile = t1File
            roiFile = roiFile.replace('T1map', 'rois')
            roiPath = Path(data_folder_name) / roiFile 
            roi = nib.load(roiPath)
            roi_data = roi.get_fdata()

    if 'NIST' in sample_type:
        dataset_series.update({
            'T1 - genu (WM)': None,
            'T1 - splenium (WM)': None,
            'T1 - deep GM': None,
            'T1 - cortical GM': None,
        })
        dataset_series.update({
            'T1 - NIST sphere 1': None,
            'T1 - NIST sphere 2': None,
            'T1 - NIST sphere 3': None,
            'T1 - NIST sphere 4': None,
            'T1 - NIST sphere 5': None,
            'T1 - NIST sphere 6': None,
            'T1 - NIST sphere 7': None,
            'T1 - NIST sphere 8': None,
            'T1 - NIST sphere 9': None,
            'T1 - NIST sphere 10': None,
            'T1 - NIST sphere 11': None,
            'T1 - NIST sphere 12': None,
            'T1 - NIST sphere 13': None,
            'T1 - NIST sphere 14': None,
        })
    else:
        roi_1_indexes=np.where(np.isclose(np.squeeze(roi_data),1,atol=0.01))
        roi_2_indexes=np.where(np.isclose(np.squeeze(roi_data),2,atol=0.01))
        roi_3_indexes=np.where(np.isclose(np.squeeze(roi_data),3,atol=0.01))
        roi_4_indexes=np.where(np.isclose(np.squeeze(roi_data),4,atol=0.01))

        dataset_series.update({
            'T1 - genu (WM)': t1_data[roi_1_indexes],
            'T1 - splenium (WM)': t1_data[roi_2_indexes],
            'T1 - deep GM': t1_data[roi_3_indexes],
            'T1 - cortical GM': t1_data[roi_4_indexes],
        })
        dataset_series.update({
            'T1 - NIST sphere 1': None,
            'T1 - NIST sphere 2': None,
            'T1 - NIST sphere 3': None,
            'T1 - NIST sphere 4': None,
            'T1 - NIST sphere 5': None,
            'T1 - NIST sphere 6': None,
            'T1 - NIST sphere 7': None,
            'T1 - NIST sphere 8': None,
            'T1 - NIST sphere 9': None,
            'T1 - NIST sphere 10': None,
            'T1 - NIST sphere 11': None,
            'T1 - NIST sphere 12': None,
            'T1 - NIST sphere 13': None,
            'T1 - NIST sphere 14': None,
        })

    return dataset_series
