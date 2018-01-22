# Decode with a Kaldi based ASR System

## Set up Conda Environment

To install conda env, run

    $ conda env create -f environment.yml

To activate the environment, type

    $ source activate mh-kaldi-decode

To deactivate it, type

    $ source deactivate

## Credentials for AWS User with Read Access to all AWS S3 buckets

Kaldi needs SRILM to compile, but it can only be downloaded after
filling out a form on a web site. To be able to fully automatically
build Kaldi, SRILM must be present on an AWS S3 bucket (see
`SRILM_REMOTE_LOCATION` in `vagrant-sync-folder/bootstrap-02-kaldi.sh`
for the name of the bucket). To allow the scripts to download files
from all AWS S3 buckets, perform the following steps:

1. Create a user on AWS with read-only access to all S3 buckets.

2. Create a file `vagrant-sync-folder/aws_credentials.txt` with the content:

   ```
   access_key_id=<AWS_ACCESS_KEY>
   secret_access_key=<AWS_SECRET_ACCESS_KEY>
   user=<AWS_USER_NAME>
   ```

## Notes

`/usr/lib/pkgconfig/kaldi-asr.pc`:
```
kaldi_root=/home/mpuels/projects/kaldi

Name: kaldi-asr
Description: kaldi-asr speech recognition toolkit
Version: 5.2
Requires: lapack-atlas
Libs: -L${kaldi_root}/tools/openfst/lib -L${kaldi_root}/src/lib -lkaldi-decoder -lkaldi-lat -lkaldi-fstext -lkaldi-hmm -lkaldi-feat -lkaldi-transform -lkaldi-gmm -lkaldi-tree -lkaldi-util -lkaldi-matrix -lkaldi-base -lkaldi-nnet3 -lkaldi-online2 -lkaldi-cudamatrix -lkaldi-ivector -lfst
Cflags: -I${kaldi_root}/src  -I${kaldi_root}/tools/openfst/include

```

    $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mpuels/projects/kaldi/tools/openfst/lib
    $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/mpuels/projects/kaldi/src/lib
    $ sudo ldconfig
    $ cd ~/projects/py-kaldi-asr/kaldiasr
    $ ldd nnet3.cpython-36m-x86_64-linux-gnu.so

	linux-vdso.so.1 =>  (0x00007ffda1d7d000)
	libkaldi-decoder.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-decoder.so (0x00007fc95e8b3000)
	libkaldi-lat.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-lat.so (0x00007fc95df2f000)
	libkaldi-fstext.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-fstext.so (0x00007fc95dc9b000)
	libkaldi-hmm.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-hmm.so (0x00007fc95d6a7000)
	libkaldi-feat.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-feat.so (0x00007fc95d424000)
	libkaldi-transform.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-transform.so (0x00007fc95d17f000)
	libkaldi-gmm.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-gmm.so (0x00007fc95ced9000)
	libkaldi-tree.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-tree.so (0x00007fc95cb98000)
	libkaldi-util.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-util.so (0x00007fc95c8f6000)
	libkaldi-matrix.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-matrix.so (0x00007fc95c5d6000)
	libkaldi-base.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-base.so (0x00007fc95c3cd000)
	libkaldi-nnet3.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-nnet3.so (0x00007fc95b79c000)
	libkaldi-online2.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-online2.so (0x00007fc95b434000)
	libkaldi-cudamatrix.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-cudamatrix.so (0x00007fc95b1c3000)
	libkaldi-ivector.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-ivector.so (0x00007fc95af51000)
	libfst.so.7 => /home/mpuels/projects/kaldi/tools/openfst/lib/libfst.so.7 (0x00007fc95a805000)
	liblapack.so.3 => /usr/lib/liblapack.so.3 (0x00007fc95a022000)
	libstdc++.so.6 => /home/mpuels/miniconda3/envs/py-kaldi-asr/lib/libstdc++.so.6 (0x00007fc959ce8000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fc9599df000)
	libgcc_s.so.1 => /home/mpuels/miniconda3/envs/py-kaldi-asr/lib/libgcc_s.so.1 (0x00007fc9597cd000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007fc9595b0000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fc9591e6000)
	libcblas.so.3 => /usr/lib/libcblas.so.3 (0x00007fc958fc4000)
	liblapack_atlas.so.3 => /usr/lib/liblapack_atlas.so.3 (0x00007fc958d68000)
	libkaldi-chain.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-chain.so (0x00007fc9581eb000)
	libkaldi-nnet2.so => /home/mpuels/projects/kaldi/src/lib/libkaldi-nnet2.so (0x00007fc957945000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007fc957741000)
	libopenblas.so.0 => /usr/lib/libopenblas.so.0 (0x00007fc9556ad000)
	libgfortran.so.3 => /usr/lib/x86_64-linux-gnu/libgfortran.so.3 (0x00007fc955382000)
	/lib64/ld-linux-x86-64.so.2 (0x00007fc95f3bc000)
	libatlas.so.3 => /usr/lib/libatlas.so.3 (0x00007fc954de4000)
	libf77blas.so.3 => /usr/lib/libf77blas.so.3 (0x00007fc954bc4000)
	libquadmath.so.0 => /home/mpuels/miniconda3/envs/py-kaldi-asr/lib/libquadmath.so.0 (0x00007fc954993000)
