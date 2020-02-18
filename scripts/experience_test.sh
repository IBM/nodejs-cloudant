#!/usr/bin/env bash

echo "Downloading and installing pip..."
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py
pip -V

echo "Installing Selenium Python package..."
pip install selenium

echo "Running UI test using Selenium..."
python3 node_cloudant.py
