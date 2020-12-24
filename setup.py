from setuptools import setup, find_packages
from codecs import open
from os import path

import src


here = path.abspath(path.dirname(__file__))

with open(path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read()

req_path = path.join(here, "requirements.txt")
with open(req_path, "r") as f:
    install_reqs = f.read().strip()
    install_reqs = install_reqs.split("\n")

setup(
    name="src",
    description="RRSG Analysis",
    long_description=long_description,
    url="https://github.com/rrsg2020/analysis",
    author="Mathieu Boudreau, PhD",
    author_email="mathieu.boudreau2@mail.mcgill.ca",
    license="MIT",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.6",
    ],
    keywords="",
    packages=find_packages(exclude=["test", "configs", "databases", "docs", "plots", "nist_phantom_tools"]),
    install_requires=install_reqs,
    package_dir={"src": "src"},
)
