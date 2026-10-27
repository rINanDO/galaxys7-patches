#!/usr/bin/env bash
#
# Applies the herolte patch set on top of a synced LineageOS 24.0 tree.
#
# Usage: ./apply.sh [source-root]
#   source-root defaults to the current directory
#
# The repository list lives in common.sh. A repo whose patches don't apply is
# left in the middle of `git am` so it can be resolved by hand; revert.sh
# cleans that up. The optional features/*/ patch sets have their own scripts.

# When sourced, re-run in a child shell so `exit` and shell options can't
# leak into (or close) the calling terminal.
if (return 0 2>/dev/null); then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

init apply "${1:-}"
apply_patches
finish
