#!/bin/bash

BAO_BIN="./bin/bao"
export BAO_ADDR="http://ws-server-$WORKSPACE_ID-openbao.workspaces:3000"
export PATH=$PATH:$(pwd)/bin

echo "--- Starting OpenBao Test ---"
echo "Target: $BAO_ADDR"

if [ ! -f "$BAO_BIN" ]; then
    echo "ERROR: OpenBao binary not found at $BAO_BIN"
    exit 1
fi

if [ -z "$BAO_ADMIN_USER" ] || [ -z "$BAO_ADMIN_PASSWORD" ]; then
    echo "ERROR: BAO_ADMIN_USER or BAO_ADMIN_PASSWORD env vars are missing."
    exit 1
fi

echo "[Test] Logging in as user '$BAO_ADMIN_USER'..."

LOGIN_RESPONSE=$($BAO_BIN write -format=json auth/userpass/login/$BAO_ADMIN_USER password="$BAO_ADMIN_PASSWORD")
ADMIN_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r .auth.client_token)

if [ -z "$ADMIN_TOKEN" ] || [ "$ADMIN_TOKEN" == "null" ]; then
    echo "ERROR: Login failed. Could not get token for user '$BAO_ADMIN_USER'."
    exit 1
fi

export BAO_TOKEN="$ADMIN_TOKEN"
echo "[Test] Successfully logged in as Admin."

NEW_ENGINE="cs-secrets-engine-3"
echo "[Test] Enabling new KV secrets engine at '$NEW_ENGINE/'..."
$BAO_BIN secrets enable -path=$NEW_ENGINE -version=2 kv 2>/dev/null || echo "   (Engine probably already exists, continuing...)"

TEST_PATH="$NEW_ENGINE/my-secret"
TEST_KEY="demo-key"
TEST_VALUE="admin-test-$(date +%s)"

echo "[Test] Writing secret to '$TEST_PATH'..."
$BAO_BIN kv put "$TEST_PATH" "$TEST_KEY=$TEST_VALUE"

echo "[Test] Reading secret back..."
READ_VALUE=$($BAO_BIN kv get -format=json "$TEST_PATH" | jq -r ".data.data[\"$TEST_KEY\"] // .data[\"$TEST_KEY\"]")

echo "---------------------------------------------------"
echo "Expected: $TEST_VALUE"
echo "Got:      $READ_VALUE"
echo "---------------------------------------------------"

if [ "$READ_VALUE" == "$TEST_VALUE" ]; then
    echo "SUCCESS: Read/Write test passed with Admin User!"
else
    echo "ERROR: Value mismatch!"
fi