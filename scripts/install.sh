#!/bin/bash

set -e

API_URL="https://api.github.com/repos/openbao/openbao/releases/latest"
VERSION_TAG=$(curl -s $API_URL | grep '"tag_name"' | head -n 1 | awk -F'"' '{print $4}')

VERSION=$(echo $VERSION_TAG | sed 's/^v//')

FILENAME="bao_${VERSION}_linux_${BAO_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/openbao/openbao/releases/download/${VERSION_TAG}/${FILENAME}"

curl -L -f -o $FILENAME $DOWNLOAD_URL

tar xzf $FILENAME bao

rm $FILENAME