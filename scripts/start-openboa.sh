#!/bin/bash

CONFIG_FILE="/home/user/app/openbao.hcl"

echo "Starting OpenBao Server in the background..."
./bao server -config=$CONFIG_FILE