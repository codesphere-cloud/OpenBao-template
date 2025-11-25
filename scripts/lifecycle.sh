#!/bin/bash
set -e

DATA_DIR="/home/user/app/openbao-data"
KEY_FILE="$DATA_DIR/keys.json"
export BAO_ADDR='http://127.0.0.1:3000'
export PATH=$PATH:$(pwd)/bin

echo "--- [Lifecycle Manager] Started ---"

echo "[Lifecycle] Waiting for OpenBao API..."
until curl -s $BAO_ADDR/v1/sys/health > /dev/null; do
    sleep 1
done

INIT_STATUS=$(bao status -format=json | jq -r .initialized)
FRESH_INSTALL="false"

if [ "$INIT_STATUS" == "false" ]; then
    echo "[Lifecycle] System is NOT initialized. Starting initialization..."
		
		mkdir -p "$DATA_DIR"
    if [ -f "$KEY_FILE" ]; then
        rm "$KEY_FILE"
    fi

    bao operator init -key-shares=1 -key-threshold=1 -format=json > $KEY_FILE
    chmod 400 $KEY_FILE
    
    FRESH_INSTALL="true"
    echo "[Lifecycle] Keys generated and saved."
else
    echo "[Lifecycle] System is already initialized."
fi

SEALED_STATUS=$(bao status -format=json | jq -r .sealed)

if [ "$SEALED_STATUS" == "true" ]; then
    echo "[Lifecycle] System is SEALED. Attempting auto-unseal..."

    if [ -f "$KEY_FILE" ]; then
        UNSEAL_KEY=$(jq -r .unseal_keys_b64[0] $KEY_FILE)
        
        if [ -n "$UNSEAL_KEY" ] && [ "$UNSEAL_KEY" != "null" ]; then
            bao operator unseal $UNSEAL_KEY
            echo "[Lifecycle] System successfully unsealed."
        else
            echo "[Lifecycle] ERROR: Keyfile is empty or invalid."
            exit 1
        fi
    else
        echo "[Lifecycle] ERROR: System is sealed, but key file ($KEY_FILE) not found!"
        exit 1
    fi
else
    echo "[Lifecycle] System is already unsealed."
fi

if [ "$FRESH_INSTALL" == "true" ]; then
    echo "[Lifecycle] Fresh install detected. Configuring admin user..."
    
    ROOT_TOKEN=$(jq -r .root_token $KEY_FILE)
    export BAO_TOKEN=$ROOT_TOKEN

    bao auth enable userpass 2>/dev/null || true

		echo 'path "*" { capabilities = ["create", "read", "update", "delete", "list", "sudo"] }' | bao policy write admin-policy -
    echo "[Lifecycle] Policy 'admin-policy' written/updated."

    if [ -n "$BAO_ADMIN_USER" ] && [ -n "$BAO_ADMIN_PASSWORD" ]; then
        bao write auth/userpass/users/$BAO_ADMIN_USER \
            password="$BAO_ADMIN_PASSWORD" \
            token_policies="superuser"
        echo "[Lifecycle] Admin user '$BAO_ADMIN_USER' created."
    else
        echo "[Lifecycle] WARNING: No admin credentials set in environment variables."
    fi
fi

echo "--- [Lifecycle Manager] Setup complete ---"