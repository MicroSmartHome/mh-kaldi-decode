#!/usr/bin/env bash

set -e -o pipefail -u

BOOTSTRAP_00_LIB_SH=/vagrant/bootstrap-00-lib.sh
if [ -f ${BOOTSTRAP_00_LIB_SH} ]; then
    . ${BOOTSTRAP_00_LIB_SH}
else
    echo "Error: Could not find ${BOOTSTRAP_00_LIB_SH}."
    exit 1
fi

DEBS="libatlas-base-dev"
KALDI_ASR_PC_PATH=/usr/lib/pkgconfig/kaldi-asr.pc

main() {
    echo "Installing .deb dependencies of mh-kaldi-decode."
    apt-get install -y ${DEBS}

    write_usr_lib_pkgconfig_kaldi_asr_pc ${KALDI_ASR_PC_PATH} ${KALDI_EXPERIMENTS_ROOT}
}

write_usr_lib_pkgconfig_kaldi_asr_pc() { # kaldi_asr_pc_path, kaldi_root
    local kaldi_asr_pc_path=$1; shift
    local kaldi_root=$1

    echo "Writing file ${kaldi_asr_pc_path}"

cat > ${kaldi_asr_pc_path} <<EOF
kaldi_root=${kaldi_root}/kaldi

Name: kaldi-asr
Description: kaldi-asr speech recognition toolkit
Version: 5.2
Requires: lapack-atlas
Libs: -L\${kaldi_root}/tools/openfst/lib -L\${kaldi_root}/src/lib -lkaldi-decoder -lkaldi-lat -lkaldi-fstext -lkaldi-hmm -lkaldi-feat -lkaldi-transform -lkaldi-gmm -lkaldi-tree -lkaldi-util -lkaldi-matrix -lkaldi-base -lkaldi-nnet3 -lkaldi-online2 -lkaldi-cudamatrix -lkaldi-ivector -lfst
Cflags: -I\${kaldi_root}/src  -I\${kaldi_root}/tools/openfst/include
EOF
}

main
