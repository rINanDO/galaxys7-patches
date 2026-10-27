#!/usr/bin/env bash
#
# Applies the experimental GCC 13 kernel patches. Apply the LOS-24.0
# patches (../../apply.sh) first.
#
# Usage: ./apply.sh [source-root]
#   source-root defaults to the current directory
#
# A repo whose patches don't apply is left in the middle of `git am` so it
# can be resolved by hand; revert.sh cleans that up.

# When sourced, re-run in a child shell so `exit` and shell options can't
# leak into (or close) the calling terminal.
if (return 0 2>/dev/null); then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/../../common.sh"

PATCH_SET="gcc13-experimental patches"
PATCHES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PATCHED_REPOS=(
    "device/samsung/universal8890-common   device_samsung_universal8890-common"
    "kernel/samsung/universal8890          kernel_samsung_universal8890"
)

init apply "${1:-}"
apply_patches
finish
