#!/usr/bin/env bash

# Compile Kaldi
#
# The script will also download and compile SRILM.

set -e -o pipefail -u

BOOTSTRAP_00_LIB_SH=/vagrant/bootstrap-00-lib.sh
if [ -f ${BOOTSTRAP_00_LIB_SH} ]; then
    . ${BOOTSTRAP_00_LIB_SH}
else
    echo "Error: Could not find ${BOOTSTRAP_00_LIB_SH}."
    exit 1
fi


KALDI_GIT_URL=https://github.com/kaldi-asr/kaldi.git
KALDI_GIT_HASH=e9abbff99a2167eb2c00e5c12495fa3f005f3db9
KALDI_GIT_BRANCH_NAME=kaldi-experiments

CONDA_ENV_NAME=kaldi
CONDA_ENV_YML=/vagrant/environment-kaldi.yml

SRILM_REMOTE_LOCATION=s3://mh-kaldi-dependencies/srilm-1.7.2.tar.gz

# Will be passed to instances of `$ make -j`, i.e. number of processes to start
# for compilation.
MAKE_J_OPTION=1

main() {
    clone_kaldi ${KALDI_EXPERIMENTS_ROOT} \
                ${KALDI_GIT_URL} \
                ${KALDI_GIT_HASH} \
                ${KALDI_GIT_BRANCH_NAME}

    # If this bash script is called with 'su ${USER_} -c ...', then
    # miniconda is not on the PATH variable. But we need miniconda to
    # activate environments.
    export PATH=${HOME}/miniconda3/bin:$PATH

    set_up_conda_env ${CONDA_ENV_NAME} ${CONDA_ENV_YML}

    set +u
    source activate ${CONDA_ENV_NAME}
    set -u

    #download_and_compile_srilm ${KALDI_EXPERIMENTS_ROOT}

    #compile_sequitur ${KALDI_EXPERIMENTS_ROOT}

    compile_kaldi_tools ${KALDI_EXPERIMENTS_ROOT} ${MAKE_J_OPTION}

    compile_kaldi ${KALDI_EXPERIMENTS_ROOT} ${MAKE_J_OPTION}

    #configure_voxforge_recipe ${KALDI_EXPERIMENTS_ROOT}
}

clone_kaldi() { # kaldi_experiments_root, git_url, git_hash, git_branch_name
    local kaldi_experiments_root=$1; shift
    local git_url=$1; shift
    local git_hash=$1; shift
    local git_branch_name=$1

    mkdir -p ${kaldi_experiments_root}

    if [ ! -d ${kaldi_experiments_root}/kaldi ]; then
        echo "Directory ${kaldi_experiments_root}/kaldi doesn't exist. Cloning Kaldi."
        pushd ${kaldi_experiments_root}
        git clone ${git_url}
        cd kaldi
        git checkout ${git_hash}
        git checkout -b ${git_branch_name}
        popd
    else
        echo "Directory ${kaldi_experiments_root}/kaldi exists. Not cloning Kaldi."
    fi
}

download_and_compile_srilm() { # kaldi_experiments_root
    local kaldi_experiments_root=$1

    local srilm_package=${kaldi_experiments_root}/kaldi/tools/srilm.tgz
    if [ ! -f ${srilm_package} ]; then
        echo "File ${srilm_package} doesn't exist. Downloading it from ${SRILM_REMOTE_LOCATION}."
        wget ${SRILM_REMOTE_LOCATION} -O ${srilm_package}
    fi

    echo "Compiling SRILM."
    pushd ${kaldi_experiments_root}/kaldi/tools
    extras/install_srilm.sh
    popd
    echo "Done compiling SRILM."
}

compile_sequitur() { # kaldi_experiments_root
    local kaldi_experiments_root=$1

    echo "Compiling Sequitur."
    pushd ${kaldi_experiments_root}/kaldi/tools

    # `set +u` necessary. Otherwise Bash terminates with error message:
    # /home/ubuntu/anaconda3/bin/deactivate: line 55: CONDA_PATH_BACKUP: unbound variable
    set +u
    source activate python2
    set -u

    extras/install_sequitur.sh
    source deactivate
    popd
    echo "Done compiling Sequitur."
}

compile_kaldi_tools() { # kaldi_experiments_root, make_j_option
    local kaldi_experiments_root=$1
    local make_j_option=$2

    echo "Compiling Kaldi tools"
    pushd ${kaldi_experiments_root}/kaldi/tools
    make -j${make_j_option}
    popd
    echo "Done compiling Kaldi tools"
}

compile_kaldi() { # kaldi_experiments_root, make_j_option
    local kaldi_experiments_root=$1
    local make_j_option=$2

    echo "Compiling Kaldi"
    pushd ${kaldi_experiments_root}/kaldi/src
    ./configure --shared
    make depend -j ${make_j_option}
    make -j ${make_j_option}
    popd
    echo "Done compiling Kaldi"
}

configure_voxforge_recipe() { # kaldi_experiments_root
    local kaldi_experiments_root=$1

    local cmd_sh=${kaldi_experiments_root}/kaldi/egs/voxforge/s5/cmd.sh
    echo "Replacing ${cmd_sh} (queue.pl -> run.pl)."
    cat > ${cmd_sh} <<EOF
# you can change cmd.sh depending on what type of queue you are using.
# If you have no queueing system and want to run on a local machine, you
# can change all instances 'queue.pl' to run.pl (but be careful and run
# commands one by one: most recipes will exhaust the memory on your
# machine).  queue.pl works with GridEngine (qsub).  slurm.pl works
# with slurm.  Different queues are configured differently, with different
# queue names and different ways of specifying things like memory;
# to account for these differences you can create and edit the file
# conf/queue.conf to match your queue's configuration.  Search for
# conf/queue.conf in http://kaldi-asr.org/doc/queue.html for more information,
# or search for the string 'default_config' in utils/queue.pl or utils/slurm.pl.

#export train_cmd="queue.pl --mem 2G"
#export decode_cmd="queue.pl --mem 4G"
#export mkgraph_cmd="queue.pl --mem 8G"

export train_cmd="run.pl"
export decode_cmd="run.pl"
export mkgraph_cmd="run.pl"
EOF
}

main
