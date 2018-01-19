#!/usr/bin/env bash

conda env export -n mh-kaldi-decode |\
    grep -v "^prefix:" \
    > environment.yml
