#!/usr/bin/env python3
"""
Setup script for ReproLab JupyterLab Extension
"""

import os
import sys
from setuptools import setup

# Read the README file
this_directory = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(this_directory, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

# Read requirements
with open('requirements.txt') as f:
    requirements = [line.strip() for line in f if line.strip() and not line.startswith('#')]

setup(
    name='reprolab',
    version='0.1.0',
    description='One step closer to reproducible research',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Piotr Witek',
    author_email='witekpiotrdev@gmail.com',
    url='https://github.com/yourusername/reprolab',
    packages=['reprolab'],
    include_package_data=True,
    install_requires=requirements,
    python_requires='>=3.9',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Science/Research',
        'License :: OSI Approved :: BSD License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
        'Framework :: Jupyter',
        'Framework :: Jupyter :: JupyterLab',
        'Framework :: Jupyter :: JupyterLab :: 4',
        'Framework :: Jupyter :: JupyterLab :: Extensions',
    ],
    keywords='jupyter jupyterlab reproducibility research science',
    zip_safe=False,
    entry_points={
        'jupyter_server_extension': [
            'reprolab = reprolab.server:load_jupyter_server_extension',
        ],
        'jupyterlab.labextension': [
            'reprolab = reprolab.labextension',
        ],
    },
) 
