USER_=vagrant

# Must be the same as `config.persistent_storage.mountpoint` in ../Vagrantfile.
WORKSTORAGE_ROOT=/workstorage

KALDI_EXPERIMENTS_ROOT=${WORKSTORAGE_ROOT}

set_up_conda_env() { # conda_env_name, conda_env_yml
    local conda_env_name=$1; shift
    local conda_env_yml=$1

    # If this bash script is called with 'su ${USER_} -c ...', then
    # Miniconda is not on the PATH variable.
    export PATH=/home/${USER_}/miniconda3/bin:$PATH

    if conda env list | grep "^${conda_env_name} " -q; then
        echo "Conda environment '${conda_env_name}' already exists."
    else
        echo "Creating Conda environment '${conda_env_name}' with ${conda_env_yml}."
        conda env create -f ${conda_env_yml}
    fi
}
