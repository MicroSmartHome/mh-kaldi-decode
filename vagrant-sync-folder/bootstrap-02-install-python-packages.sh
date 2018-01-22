#!/usr/bin/env bash

set -e -o pipefail -u

main() {
    echo "Installing Python packages."

    # If this bash script is called with 'su ${USER_} -c ...', then
    # Miniconda is not on the PATH variable. But this script relies on
    # Miniconda for pip.
    export PATH=${HOME}/miniconda3/bin:$PATH
    pip install awscli==1.14.1
}

main
