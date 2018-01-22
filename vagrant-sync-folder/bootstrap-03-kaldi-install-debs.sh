#!/usr/bin/env bash

DEBS="\
automake \
autoconf \
build-essential \
libatlas3-base \
libtool \
zlib1g-dev \
"

main() {
    apt-get install -y ${DEBS}
}

main
