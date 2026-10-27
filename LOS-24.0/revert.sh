#!/usr/bin/env bash
#
# Reverts the herolte patch set: aborts any unfinished `git am` and resets
# each patched repository to its manifest revision with `repo sync`.
#
# Usage: ./revert.sh [source-root]
#   source-root defaults to the current directory
#
# The repository list lives in common.sh. The optional features/*/ patch sets
# have their own revert.sh.

# When sourced, re-run in a child shell so `exit` and shell options can't
# leak into (or close) the calling terminal.
if (return 0 2>/dev/null); then
    bash "${BASH_SOURCE[0]}" "$@"
    return
fi

set -uo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

init revert "${1:-}"
revert_patches
finish
