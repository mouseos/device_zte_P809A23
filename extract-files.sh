#!/bin/bash
# Pull proprietary blobs listed in proprietary-files.txt from a connected
# device (adb, root) into ../../../vendor/zte/P809A23. CM-12.1 mechanism.
set -e
VENDOR=zte
DEVICE=P809A23
export DEVICE_COMMON=
DIR="$(cd "$(dirname "$0")" && pwd)"
CM_ROOT="$DIR"/../../..
HELPER="$CM_ROOT"/vendor/cm/build/tools/extract_utils.sh
[ -f "$HELPER" ] || { echo "$HELPER not found (sync the CM-12.1 tree first)"; exit 1; }
. "$HELPER"
setup_vendor "$DEVICE" "$VENDOR" "$CM_ROOT"
extract "$DIR"/proprietary-files.txt "${1:-adb}" "${2:-}"
"$DIR"/setup-makefiles.sh
