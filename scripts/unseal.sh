#!/bin/bash

set -e

KEY_FILE="/home/user/app/.codesphere-internal/keys.txt"
export BAO_ADDR='http://ws-server-73051-openbao.workspaces:3000'

if [ ! -f "$KEY_FILE" ]; then
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "ERROR: Server is sealed, but key file ($KEY_FILE) was not found!"
		echo "Cannot unseal."
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1 
else
		UNSEAL_KEY=$(grep 'Unseal Key 1:' $KEY_FILE | awk '{print $4}')
		
		if [ -z "$UNSEAL_KEY" ]; then
				echo "ERROR: Could not read unseal key from $KEY_FILE."
		else
				./bao operator unseal $UNSEAL_KEY
				echo "Server unsealed successfully."
		fi
fi