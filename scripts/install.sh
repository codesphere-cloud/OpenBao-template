#!/bin/bash

set -e

mkdir -p ./bin
export PATH=$PATH:$(pwd)/bin

echo "Installing OpenBao..."
API_URL="https://api.github.com/repos/openbao/openbao/releases/latest"
VERSION_TAG=$(curl -s $API_URL | grep '"tag_name"' | head -n 1 | awk -F'"' '{print $4}')
VERSION=$(echo $VERSION_TAG | sed 's/^v//')
ARCH=$(uname -m)

ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    MAPPED_ARCH="amd64"
		JQ_ARCH="linux64"
elif [ "$ARCH" == "aarch64" ]; then
    MAPPED_ARCH="arm64"
		JQ_ARCH="linux-arm64"
else
    MAPPED_ARCH="$ARCH"
		JQ_ARCH="$ARCH"
fi

FILENAME="bao_${VERSION}_linux_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/openbao/openbao/releases/download/${VERSION_TAG}/${FILENAME}"
echo $DOWNLOAD_URL
curl -L -f -o $FILENAME $DOWNLOAD_URL

tar xzf $FILENAME -C ./bin bao
rm $FILENAME

echo "Installing Process-Compose..."
PC_API_URL="https://api.github.com/repos/F1bonacc1/process-compose/releases/latest"
PC_TAG=$(curl -s $PC_API_URL | grep '"tag_name"' | head -n 1 | awk -F'"' '{print $4}')

PC_FILENAME="process-compose_linux_${MAPPED_ARCH}.tar.gz"
PC_DL_URL="https://github.com/F1bonacc1/process-compose/releases/download/${PC_TAG}/${PC_FILENAME}"
curl -L -f -o pc.tar.gz $PC_DL_URL
tar xzf pc.tar.gz -C ./bin process-compose
rm pc.tar.gz

JQ_API_URL="https://api.github.com/repos/jqlang/jq/releases/latest"
JQ_TAG=$(curl -s $JQ_API_URL | grep '"tag_name"' | head -n 1 | awk -F'"' '{print $4}')
JQ_DL_URL="https://github.com/jqlang/jq/releases/download/${JQ_TAG}/jq-${JQ_ARCH}"

echo "Downloading jq ${JQ_TAG}..."
curl -L -f -o ./bin/jq $JQ_DL_URL

chmod +x ./bin/jq
chmod +x ./bin/bao
chmod +x ./bin/process-compose
chmod +x ./scripts/lifecycle.sh
chmod +x ./scripts/test.sh
