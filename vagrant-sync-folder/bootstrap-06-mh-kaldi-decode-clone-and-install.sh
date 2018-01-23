#!/usr/bin/env bash

set -e -o pipefail -u

BOOTSTRAP_00_LIB_SH=/vagrant/bootstrap-00-lib.sh
if [ -f ${BOOTSTRAP_00_LIB_SH} ]; then
    . ${BOOTSTRAP_00_LIB_SH}
else
    >&2 echo "Error: Could not find ${BOOTSTRAP_00_LIB_SH}."
    exit 1
fi

MH_KALDI_DECODE_GIT_REPO_NAME=mh-kaldi-decode
MH_KALDI_DECODE_GIT_URL=https://github.com/mpuels/${MH_KALDI_DECODE_GIT_REPO_NAME}.git
MH_KALDI_DECODE_ROOT=/home/${USER_}/projects/${MH_KALDI_DECODE_GIT_REPO_NAME}

CONDA_ENV_NAME=mh-kaldi-decode
CONDA_ENV_YML=${MH_KALDI_DECODE_ROOT}/environment.yml

main() {
    echo "PATH=$PATH"

    clone_git_repo ${MH_KALDI_DECODE_GIT_URL} ${MH_KALDI_DECODE_ROOT}

    set_up_conda_env ${CONDA_ENV_NAME} ${CONDA_ENV_YML}

    in_bashrc_append_ld_library_path ${KALDI_EXPERIMENTS_ROOT}/kaldi
}

clone_git_repo() { # mh_kaldi_decode_git_url, mh_kaldi_decode_root
    local mh_kaldi_decode_git_url=$1; shift
    local mh_kaldi_decode_root=$1

    if [ -d "${mh_kaldi_decode_root}" ]; then
        echo "Directory ${mh_kaldi_decode_root} already exists. Not cloning repo."
    else
        local projects_root=$(dirname ${mh_kaldi_decode_root})
        mkdir -p ${projects_root}
        echo "Cloning ${mh_kaldi_decode_git_url} into $(dirname ${projects_root})"
        pushd ${projects_root}
        git clone ${mh_kaldi_decode_git_url}
        popd
    fi
}

in_bashrc_append_ld_library_path() { # kaldi_root
    local kaldi_root=$1

    local path_tools_openfst_lib=${kaldi_root}/tools/openfst/lib
    local path_src_lib=${kaldi_root}/src/lib

    if grep -q ${path_tools_openfst_lib} ${HOME}/.bashrc; then
        echo "Not appending paths to Kaldi libs to LD_LIBRARY_PATH in .bashrc"
    else
        echo "Appending paths to Kaldi libs to LD_LIBRARY_PATH in .bashrc"
        echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$path_tools_openfst_lib:$path_src_lib" \
             >> ${HOME}/.bashrc
    fi
}

main
