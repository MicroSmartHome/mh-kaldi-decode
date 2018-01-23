# Decode with a Kaldi based ASR System on a Virtual Machine

With this repository it's possible to create a virtual machine that
hosts a Kaldi based speech to text system. All that is required is a
trained model. The scripts contained here take care of the following
for you on the virtual machine:

- install [Kaldi](https://github.com/kaldi-asr/kaldi)'s compilation
  dependencies
- clone Kaldi from the official repository
- create a defined Conda environment for the compilation of Kaldi
- compile Kaldi (look at `KALDI_GIT_HASH` in
  [bootstrap-04-kaldi-clone-and-compile.sh](vagrant-sync-folder/bootstrap-04-kaldi-clone-and-compile.sh)
  to see which commit is compiled)
- install [py-kaldi-asr](https://github.com/gooofy/py-kaldi-asr)'s
  requirements and configure the system so that py-kaldi-asr can find
  Kaldi during compilation
- create a defined Conda environment
  ([environment.yml](environment.yml)) containing py-kaldi-asr


## Requirements

- VirtualBox 5
- Vagrant
- Miniconda (Optional. Only required, if you want to run Python code
  on the host machine.)


## Set up Vagrant Machine and Decode Audio Recordings

To set up the virtual machine and decode audio recordings with Kaldi,
perform the following steps

    host$ vagrant plugin install vagrant-persistent-storage #  Only required once.
    host$ vagrant up
    host$ mkdir vagrant-sync-python-src/kaldi-models
    host$ cp -a PATH_TO/KALDI_MODEL vagrant-sync-python-src/kaldi-models
    host$ mkdir vagrant-sync-python-src/audio
    host$ cp PATH_TO_WAV_FILES/*.wav vagrant-sync-python-src/audio
    host$ vagrant ssh
    guest$ source activate mh-kaldi-decode
    guest$ cd /vagrant-python-src
    guest$ ./decode.py kaldi-models/KALDI_MODEL tdnn_sp audio #  Example call.
    guest$ sudo shutdown -h

Performing the second step (`vagrant up`) for the first time will take
a long time, as it will compile Kaldi. Subsequent `vagrant up`s will
be much faster.

The execution of `decode.py` above is a rough example. A concrete call
might look like this:

    ./decode.py kaldi-models/kaldi-chain-voxforge-de-r20180119 tdnn_sp audio

The directory `vagrant-sync-python-src/` on the host machine is mapped
to `/vagrant-python-src` on the guest machine. So each change made on
the host machine in that directory is instantly available on the guest
machine. That means, that you can open for example
`vagrant-sync-python-src/decode.py` on the host machine, make some
changes to it and then right away execute it on the guest machine to
test it.


## Set up Conda Environment for Development on the Host Machine

To install the Conda environment

    $ conda env create -f environment.yml

To activate the environment, type

    $ source activate mh-kaldi-decode

To deactivate it, type

    $ source deactivate

This is the same Conda environment that is used on the guest machine.


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

## Known Issues

The VM in `Vagrantfile` is configured to have 2 CPUs and 2GB of
RAM. But the amount of RAM is not enough to compile Kaldi with `make-j2`.
That's why in
[bootstrap-04-kaldi-clone-and-compile.sh](https://github.com/mpuels/mh-kaldi-decode/blob/master/vagrant-sync-folder/bootstrap-04-kaldi-clone-and-compile.sh)
`MAKE_J_OPTION` is set to 1. If your host machine has enough computing
power, you can increase the number of CPUs and the amount of RAM in
`Vagrantfile`, and increase `MAKE_J_OPTION` in
`bootstrap-04-kaldi-clone-and-compile.sh`.


## Notes

Vagrant is configured to attach a separate disk where it will download
Kaldi to and compile it. Reason: The standard disk size of the Vagrant
box ubuntu/xenial64 is just 10GB and Kaldi alone needs 8GB. Also, the
compilation process of Kaldi takes a long time so it makes sense to be
able to store a compiled Kaldi version on a separate disk which is not
destroyed on `vagrant destroy`.
