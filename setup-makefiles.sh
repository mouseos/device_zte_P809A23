#!/bin/bash
# Generate vendor/zte/P809A23 makefiles from proprietary-files.txt. CM-12.1.
set -e
VENDOR=zte
DEVICE=P809A23
DIR="$(cd "$(dirname "$0")" && pwd)"
CM_ROOT="$DIR"/../../..
HELPER="$CM_ROOT"/vendor/cm/build/tools/extract_utils.sh
[ -f "$HELPER" ] || { echo "$HELPER not found (sync the CM-12.1 tree first)"; exit 1; }
. "$HELPER"
setup_vendor "$DEVICE" "$VENDOR" "$CM_ROOT" true
write_makefiles "$DIR"/proprietary-files.txt true
