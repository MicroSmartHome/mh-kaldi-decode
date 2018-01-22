#!/usr/bin/env bash

# Update /vagrant/environment-kaldi.yml
#
# Run this script from the guest machine to update the file Conda environment
# that is required by Kaldi.

echo "Exporting Conda environment 'Kaldi' to /vagrant/environment-kaldi.yml"
conda env export -n kaldi |\
    grep -v "^prefix:" \
    > /vagrant/environment-kaldi.yml
