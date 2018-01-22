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

VM in `Vagrantfile` is configured to have 2 CPUs and 2GB of RAM. But RAM
is not enough to compile Kaldi with `make -j2`. Must use `make -j1` at the
moment.
