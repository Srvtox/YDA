#!/bin/bash

set -e

MANIFEST="manifest.txt"

FILE=$(grep original_file $MANIFEST | cut -d= -f2)

echo "Restoring $FILE ..."

cat ${FILE}.part_* > "$FILE"

echo "Checking checksum..."

sha256sum -c checksum.txt

echo "Done ✅"
