#!/bin/bash

UTCNOW=$(date --utc +%Y-%m-%d-%H%M%S)

main() {
    mkdir -p logs
    ./decode.py $@ > logs/decode-${UTCNOW}.log 2>&1
}

main $@
