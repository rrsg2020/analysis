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

def temperature_correction(input_temperature,serial_number,interpolation='quadratic'):
    if serial_number>=0:
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
        sphereID = list(phantom_v2.keys());
        temperature = list(phantom_v2['1'].keys());
    
        #Define array (data) to store data for interpolation
        data = np.empty([len(temperature),len(sphereID)+1]);
        #Fill data array
        row = 0;
        for i in temperature:
            row = row + 1;
            data[row-1,0] = int(i);
            for j in sphereID:
                T1_value = float(phantom_v2[j][i]);
                data[row-1,int(j)] = T1_value;

        ##Code for Temperature Correction: Interpolation##
        #If input_temperature is a scalar:
        #Validate input_temperature
        validTemperature = lambda input_temperature: np.isscalar(input_temperature);
        if validTemperature(input_temperature) == True:
            input2array = input_temperature;
            input_temperature = np.arange(1);
            input_temperature[0] = input2array;
    
    
        #Cubic Spline (define output as array)
        spline_estimatedT1 = np.empty([len(sphereID),len(input_temperature)]);
    
        #Cubic (define output as array)
        cubic_estimatedT1 = np.empty([len(sphereID),len(input_temperature)]);
        
        #Quadratic (define output as array. Data represented log-log)
        quadratic_estimatedT1 = np.empty([len(sphereID),len(input_temperature)]);
        
        outputArray = np.empty([len(sphereID),len(input_temperature)]);
        
        #Interpolations
        for k in range(len(sphereID)):
            for l in range(len(input_temperature)):
                if interpolation=='quadratic':
                    #log-log data representation 
                    quad = interpolate.interp1d(np.log10(data[:,0]), np.log10(data[:,k+1]), kind='quadratic');
                    quadratic_estimatedT1[k,l] = quad(np.log10(input_temperature[l]));
                    #Output temperature NOT in log scale
                    outputArray = 10 ** quadratic_estimatedT1;
                elif interpolation=='cubic':
                    #Cubic        
                    cubic = interpolate.interp1d(data[:,0], data[:,k+1], kind='cubic');
                    cubic_estimatedT1[k,l] = cubic(input_temperature[l]);
                    outputArray = cubic_estimatedT1;
                elif interpolation=='cubic-spline':
                    #Cubic Spline
                    cubicSpline = interpolate.splrep(data[:,0], data[:,k+1]);
                    spline_estimatedT1[k,l] = interpolate.splev(input_temperature[l],cubicSpline);
                    outputArray = spline_estimatedT1;
                else:
                    print('Invalid interpolation (choose from "quadratic" (default), "cubic-spline", "cubic"')
                    return None
                
        if 'input2array' in locals():
            outputArray = outputArray.reshape((len(sphereID),))
        
        return outputArray
                    
    else:
        print('Warning! Undefined functionality.')
        return None









