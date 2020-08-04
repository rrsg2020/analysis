import numpy as np

def get_reference_NIST_values(version):
    if version<42:
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
            1838,
            1398,
            998.3,
            725.8,
            509.1,
            367.0,
            258.7,
            184.7,
            130.8,
            90.9,
            64.2,
            46.28,
            32.65,
            22.95
        ])   