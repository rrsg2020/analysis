import numpy as np

def get_reference_NIST_values(serial_number):
    '''get_reference_NIST_values
    Get the reference T1 values for the CaliberMRI/NIST values of the T1 plate
    at 20C.

    The CaliberMRI/NIST quantitative MRI phantom has two versions, version 1 is
    for serial numbers <0042 and version 2 is for serial numbers >=0042.

    T1 values are in ms.

    The values for version 1 are from: https://app.box.com/s/sqeuvq6uqbgx8ixa6mcp37nbrcpndwwm
    The values for version 2 are from an internal email with CaliberMRI, which they stated will be released
    in a new technical specifications document on their website near the end of August 2020.
    '''
    if serial_number<42:
        return np.array([
            1989,
            1454,
            984.1,
            706,
            496,
            351.5,
            247.13,
            175.3,
            125.9,
            89.0,
            62.7,
            44.53,
            30.84,
            21.719
        ])
    else:
        return np.array([
            1883.97,
            1330.16,
            987.27,
            690.08,
            484.97,
            341.58,
            240.86,
            174.95,
            121.08,
            85.75,
            60.21,
            42.89,
            30.40,
            21.44
        ])   

def get_NIST_ids():
    ids = [
        'T1 - NIST sphere 1',
        'T1 - NIST sphere 2',
        'T1 - NIST sphere 3',
        'T1 - NIST sphere 4',
        'T1 - NIST sphere 5',
        'T1 - NIST sphere 6',
        'T1 - NIST sphere 7',
        'T1 - NIST sphere 8',
        'T1 - NIST sphere 9',
        'T1 - NIST sphere 10',
        'T1 - NIST sphere 11',
        'T1 - NIST sphere 12',
        'T1 - NIST sphere 13',
        'T1 - NIST sphere 14',
    ]
    return ids