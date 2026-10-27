#!/usr/bin/env bash
#
# Reverts the experimental GCC 13 kernel patches: aborts any unfinished
# `git am` and resets each patched repository to its manifest revision with
# `repo sync`.
#
# Usage: ./revert.sh [source-root]
#   source-root defaults to the current directory
#
# The LOS-24.0 patches are left in place; ../../revert.sh reverts them.

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

init revert "${1:-}"
revert_patches
finish
