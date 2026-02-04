#!/bin/bash
BAO_BIN="./bin/bao"
export BAO_ADDR="http://ws-server-$WORKSPACE_ID-openbao.workspaces:3000"
export PATH=$PATH:$(pwd)/bin

ENGINE="cs-secrets-engine-3"
LOGIN_RESPONSE=$($BAO_BIN write -format=json auth/userpass/login/$BAO_ADMIN_USER password="$BAO_ADMIN_PASSWORD")
export BAO_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r .auth.client_token)

echo "--- OpenBao Sanity Check ---"

# --- TEST 1: GRANULAR STRUCTURE (CURRENT) ---
echo -e "\n[Test 1] Granular Structure (One path per secret)..."
PATH_PARENT="granular-test"
$BAO_BIN kv put "$ENGINE/$PATH_PARENT/key1" value="content-1" > /dev/null
$BAO_BIN kv put "$ENGINE/$PATH_PARENT/key2" value="content-2" > /dev/null

echo "Deleting parent path: $PATH_PARENT"
$BAO_BIN kv metadata delete "$ENGINE/$PATH_PARENT" > /dev/null 2>&1

CHECK_GRANULAR=$($BAO_BIN kv get -format=json "$ENGINE/$PATH_PARENT/key1" 2>&1)
if [[ $CHECK_GRANULAR == *"content-1"* ]]; then
    echo "RESULT A: Deleting the parent path did NOT remove children (Expected)."
fi

# --- TEST 2: BUNDLED STRUCTURE (PARTITION AS PATH) ---
echo -e "\n[Test 2] Bundled Structure (Partition = One path)..."
PATH_PARTITION="bundled-test/workspace-123"
$BAO_BIN kv put "$ENGINE/$PATH_PARTITION" key1="content-1" key2="content-2" > /dev/null

echo "Deleting partition path: $PATH_PARTITION"
$BAO_BIN kv metadata delete "$ENGINE/$PATH_PARTITION" > /dev/null 2>&1

CHECK_BUNDLED=$($BAO_BIN kv get -format=json "$ENGINE/$PATH_PARTITION" 2>&1)
if [[ $CHECK_BUNDLED == *"No value found"* ]] || [[ $CHECK_BUNDLED == *"404"* ]]; then
    echo "RESULT B: Deleting the path removed ALL contained KV pairs (Expected)."
fi