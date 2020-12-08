import numpy as np
from scipy import interpolate

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

def temperature_correction(input_temperature):
    #Dictionary of data
    phantom_v2 = {
        '14': {'16': '21.94', '18': '21.62','20': '21.44', '22': '21.28', '24': '21.26', '26': '21.31'},
        '13': {'16': '31.05', '18': '30.65','20': '30.40', '22': '30.27', '24': '30.25', '26': '30.31'},
        '12': {'16': '43.79', '18': '43.24','20': '42.89', '22': '42.72', '24': '42.70', '26': '42.80'},
        '11': {'16': '61.49', '18': '60.70','20': '60.21', '22': '59.97', '24': '60.00', '26': '60.17'},
        '10': {'16': '87.47', '18': '86.41','20': '85.75', '22': '85.03', '24': '85.01', '26': '85.28'},
        '9': {'16': '122.99', '18': '121.79','20': '121.08', '22': '120.80', '24': '120.90', '26': '121.34'},
        '8': {'16': '177.68', '18': '175.94','20': '174.95', '22': '174.59', '24': '174.78', '26': '175.48'},
        '7': {'16': '243.77', '18': '241.84','20': '240.86', '22': '240.75', '24': '241.31', '26': '242.45'},
        '6': {'16': '343.00', '18': '341.53','20': '341.58', '22': '342.58', '24': '344.23', '26': '346.67'},
        '5': {'16': '483.91', '18': '482.91','20': '484.97', '22': '486.92', '24': '490.24', '26': '494.55'},
        '4': {'16': '675.07', '18': '686.88','20': '690.08', '22': '695.01', '24': '701.06', '26': '709.48'},
        '3': {'16': '950.71', '18': '963.56','20': '987.27', '22': '1000.81', '24': '1015.70', '26': '1030.78'},
        '2': {'16': '1274.07', '18': '1317.71','20': '1330.16', '22': '1355.29', '24': '1367.79', '26': '1395.94'},
        '1': {'16': '1766.68', '18': '1830.34','20': '1883.97', '22': '1937.34', '24': '1987.50', '26': '2066.95'}
        };
    
    ##Get keys and values of dictionary to construct a 2D array##
    #Get dictionary keys as lists
    sphere = list(phantom_v2.keys());
    temperature = list(phantom_v2['1'].keys());

    input_temperature = np.asarray(input_temperature);
    ##Code for Temperature Correction: Interpolation##
    #Cubic Spline
    cs_estimatedT1_values = np.empty([len(input_temperature),len(sphere)]);
    cs_outDic_T1values = {};
    
    #Cubic
    c_estimatedT1_values = np.empty([len(input_temperature),len(sphere)]);
    c_outDic_T1values = {};
    #Interpolations
    for k in range(len(sphere)):
        for l in range(len(input_temperature)):
            f_cubicSpline = interpolate.splrep(data2fit[:,0], data2fit[:,k+1]);
            cs_estimatedT1_values[l,k] = interpolate.splev(input_temperature[l],f_cubicSpline);
            cs_outDic_T1values[l,k+1] = cs_estimatedT1_values[l,k];
        
            f_cubic = interpolate.interp1d(data2fit[:,0], data2fit[:,k+1], kind='cubic');
            c_estimatedT1_values[l,k] = f_cubic(input_temperature[l]);
            c_outDic_T1values[l,k+1] = c_estimatedT1_values[l,k];
    
    #Interpolation of data for Sphere No. 1 only
    plt.plot(data2fit[:,0], data2fit[:,1], 'o')
    plt.plot(data2fit[:,0], cs_estimatedT1_values[:,0], '--');
    plt.plot(data2fit[:,0], c_estimatedT1_values[:,0], '-*');
    plt.legend(['data', 'cubic-spline', 'cubic'], loc='best');
    plt.title('Interpolation: Sphere No. 1');
    plt.xlabel('Temperature (°C)');
    plt.ylabel('T1 value (ms)')
    plt.show()
        
    return cs_outDic_T1values, cs_estimatedT1_values, c_outDic_T1values, c_estimatedT1_values;

#Call function with an array of temperatures as input_temperature.
temperature_correction(np.arange(16,28,2))