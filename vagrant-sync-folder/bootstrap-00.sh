#!/usr/bin/env bash

set -e -o pipefail -u

BOOTSTRAP_00_LIB_SH=/vagrant/bootstrap-00-lib.sh
if [ -f ${BOOTSTRAP_00_LIB_SH} ]; then
    . ${BOOTSTRAP_00_LIB_SH}
else
    >&2 echo "Error: Could not find ${BOOTSTRAP_00_LIB_SH}."
    exit 1
fi

DECODER_SCRIPTS_DIR=

AWS_CREDENTIALS_FILE=/vagrant/aws_credentials.txt
AWS_REGION=us-west-2

KALDI_DIR=${USER_}/projects
KALDI_GIT_URL=https://github.com/kaldi-asr/kaldi.git
KALDI_GIT_HASH=e9abbff99a2167eb2c00e5c12495fa3f005f3db9
KALDI_GIT_BRANCH_NAME=kaldi-experiments


main() {

    chown ${USER_}.${USER_} ${WORKSTORAGE_ROOT}

    install_general_debs

    su ${USER_} -c /vagrant/bootstrap-01-install-miniconda.sh

    export PATH=/home/${USER_}/miniconda3/bin:$PATH

    su ${USER_} -c /vagrant/bootstrap-02-install-python-packages.sh

    su ${USER_} -c "write_aws_config ${AWS_CREDENTIALS_FILE} ${AWS_REGION}"

    /vagrant/bootstrap-03-kaldi-install-debs.sh

    su ${USER_} -c /vagrant/bootstrap-04-kaldi-clone-and-compile.sh

    /vagrant/bootstrap-05-mh-kaldi-decode-install-debs.sh

    su ${USER_} -c /vagrant/bootstrap-06-mh-kaldi-decode-clone-and-install.sh
}

write_aws_config() { # aws_credentials_txt, aws_region
    local aws_credentials_txt=$1; shift
    local aws_region=$1

    # If `write_aws_config` is called with 'su ${USER_} -c ...', then miniconda
    # is not on the PATH variable. But we need miniconda, because we've
    # installed "awscli" with pip.
    export PATH=${HOME}/miniconda3/bin:$PATH

    if [ ! -f ${aws_credentials_txt} ]; then
        >&2 echo "File ${aws_credentials_txt} doesn't exist. Please look into "
        >&2 echo "README.md on how to create it."
        exit 1
    fi

    local access_key_id=$(grep access_key_id ${aws_credentials_txt} | cut -f2 -d=)
    local secret_access_key=$(grep secret_access_key ${aws_credentials_txt} | cut -f2 -d=)
    local user=$(grep user ${aws_credentials_txt} | cut -f2 -d=)

    [ -z "${access_key_id}" ] && \
        >&2 echo "Could not read 'access_key_id' from ${aws_credentials_txt}." && \
        exit 1

    [ -z "${secret_access_key}" ] && \
        >&2 echo "Could not read 'secret_access_key' from ${aws_credentials_txt}." && \
        exit 1

    [ -z "${user}" ] && \
        >&2 echo "Could not read 'user' from ${aws_credentials_txt}." && \
        exit 1

    echo "Writing AWS config."
    aws configure set aws_access_key_id "${access_key_id}"
    aws configure set aws_secret_access_key "${secret_access_key}"
    aws configure set default.region ${aws_region}
}

export -f write_aws_config

install_general_debs() {
    apt-get update
    apt-get install -y flac htop subversion pkg-config
}

main
