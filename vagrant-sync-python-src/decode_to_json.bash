#!/bin/bash

UTCNOW=$(date --utc +%Y-%m-%d-%H%M%S)

main() {
    mkdir -p logs
    ./decode_to_json.py $@ > logs/decode_to_json-${UTCNOW}.log 2>&1
}

main $@
