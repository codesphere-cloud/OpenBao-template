#!/bin/bash

# The server should be unsealed already (./scripts/unseal.sh)

export BAO_ADDR="https://${WORKSPACE_ID}-3000.2.codesphere.com"
echo $BAO_ADDR
KEYS_FILE=".codesphere-internal/keys.txt"

if [ ! -f "$KEYS_FILE" ]; then
    echo "File '$KEYS_FILE' not found!"
    exit 1
fi

ROOT_TOKEN=$(grep "Initial Root Token:" "$KEYS_FILE" | awk '{print $NF}')

if [ -z "$ROOT_TOKEN" ]; then
    echo "No ROOT_TOKEN in file."
    exit 1
fi

export BAO_TOKEN="$ROOT_TOKEN"


TEST_PATH="secret/test-secret"
TEST_KEY="demo-key"
TEST_VALUE="hello-world-123"

if [ -z "$BAO_TOKEN" ]; then
  echo "Error: BAO_TOKEN is not set."
  echo "Run: export BAO_TOKEN='your-token'"
  exit 1
fi

echo "Creating secret..."

./bao kv put "$TEST_PATH" "$TEST_KEY=$TEST_VALUE"

if [ $? -eq 0 ]; then
    echo "Success: Secret stored at '$PATH_NAME'."
else
    echo "Error: Failed to store secret."
    exit 1
fi