#!/usr/bin/env bash

set -e -o pipefail -u

BOOTSTRAP_00_LIB_SH=/vagrant/bootstrap-00-lib.sh
if [ -f ${BOOTSTRAP_00_LIB_SH} ]; then
    . ${BOOTSTRAP_00_LIB_SH}
else
    >&2 echo "Error: Could not find ${BOOTSTRAP_00_LIB_SH}."
    exit 1
fi


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

    /vagrant/bootstrap-03-kaldi-install-debs.sh

    su ${USER_} -c /vagrant/bootstrap-04-kaldi-clone-and-compile.sh

    /vagrant/bootstrap-05-mh-kaldi-decode-install-debs.sh

    su ${USER_} -c /vagrant/bootstrap-06-mh-kaldi-decode-clone-and-install.sh
}

install_general_debs() {
    apt-get update
    apt-get install -y flac htop subversion pkg-config
}

main
