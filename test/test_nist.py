# coding: utf-8

from pathlib import Path
import imageio
import numpy as np

import pytest

from src.nist import *


class TestCore(object):
    def setup(self):
        pass

    def teardown(self):
        pass

    @pytest.mark.unit
    def test_inputTemperature(self):
        sphere = 1;
        temperature = 20;
        testTemperature = temperature_correction(temperature,42);
        testTemperature = round(float(testTemperature[sphere-1]),2);
        referenceTemperature = float(phantom_v2.get(str(sphere),{}).get(str(temperature)));
        assert  testTemperature == referenceTemperature

    @pytest.mark.unit
    def test_formatArray(self):
        testArray = temperature_correction(20,42);
        assert np.shape(testArray) == (len(phantom_v2),1)
        assert isinstance(testArray,np.ndarray) == True