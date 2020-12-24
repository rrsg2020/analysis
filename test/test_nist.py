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
    def test_formatArray(self):
        temperature = 20
        serial_number = 42

        test_array = temperature_correction(temperature, serial_number)
        
        reference_temperature = get_reference_NIST_values(serial_number)

        assert np.shape(test_array) == (len(reference_temperature),1)
        assert isinstance(test_array,np.ndarray) == True

    @pytest.mark.unit
    def test_inputTemperature(self):
        sphere = 1
        temperature = 20
        serial_number = 42

        test_temperature = temperature_correction(temperature, serial_number)

        reference_temperature = get_reference_NIST_values(serial_number)

        assert  np.testing.assert_array_equal(test_temperature, reference_temperature)
