#!/usr/bin/env bash

set -e -o pipefail -u

main() {
    local src_url=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

    echo "${FUNCNAME[0]}"

    mkdir -p ${HOME}/progs/miniconda
    pushd ${HOME}/progs/miniconda

    if [ -f Miniconda3-latest-Linux-x86_64.sh ]; then
        echo "Skipping downloading Miniconda from ${src_url}"
    else
        echo "${FUNCNAME[0]}: Downloading ${src_url} to ${PWD}"
        wget -q ${src_url}
    fi

    if [ -d ${HOME}/miniconda3 ]; then
        echo "Skipping running the Miniconda install script"
    else
        echo "${FUNCNAME[0]}: Running the Minicdona installation script"
        bash Miniconda3-latest-Linux-x86_64.sh -b
    fi

    if grep -q miniconda3 ${HOME}/.bashrc; then
        echo "${FUNCNAME[0]}: Not appending miniconda3/bin to PATH."
    else
        echo "${FUNCNAME[0]}: Appending miniconda3/bin to PATH."
        echo "export PATH=${HOME}/miniconda3/bin:\$PATH" >> ~/.bashrc
    fi

    popd
}

main
