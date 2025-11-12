#!/bin/bash

KEY_FILE="/home/user/app/.codesphere-internal/keys.txt"
export BAO_ADDR='http://ws-server-73051-openbao.workspaces:3000'

if [ -f "$KEY_FILE" ]; then
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ERROR: Server is uninitialized, but a key file ($KEY_FILE) already exists!"
		echo "This indicates a data-loss problem (e.g., data directory was deleted)."
		echo "Please remove $KEY_FILE manually to force re-initialization."
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
fi

echo "Generating new keys and saving to $KEY_FILE..."
./bao operator init -key-shares=1 -key-threshold=1 > $KEY_FILE

echo "Initialization complete."