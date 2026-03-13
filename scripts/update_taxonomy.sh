#!/usr/bin/env bash
# File: update_taxonomy.sh 
set -e

# Require API key from environment

if [[ -z "$SOS_API_KEY" ]]; then
  echo "Error: SOS_API_KEY environment variable is not set. Please run \"source ./config/common.env\"." >&2
  exit 1
fi

if [[ -z "$SKLEPI_ROOT" ]]; then
  echo "Error: SKLEPI_ROOT environment variable is not set. Please run \"source ./config/common.env\"." >&2
  exit 1
fi


URL="https://api.artdatabanken.se/taxonservice/v1/darwincore/download"

WORKDIR="$SKLEPI_ROOT"
TMP="$WORKDIR/tmp_dwca"

mkdir -p "$TMP"
cd "$TMP"

echo "Downloading DWCA..."

curl -L \
  -H "Cache-Control: no-cache" \
  -H "Ocp-Apim-Subscription-Key: $SOS_API_KEY" \
  "$URL" \
  -o dwca.zip

echo "Unpacking..."

rm -rf unpack
mkdir unpack
unzip -q dwca.zip -d unpack

echo "Replacing taxonomy files..."

rm -rf "$WORKDIR/dwca"
mv unpack "$WORKDIR/dwca"
rm -fr "$TMP"

echo "Done."
