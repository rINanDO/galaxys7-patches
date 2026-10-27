#!/usr/bin/env bash
#
# Creates a local branch named "lineage-24.0" (from current HEAD) in every
# rinando/ repository listed in herolte-24.0.xml, and pushes it to the remote.
# The LineageOS GCC 4.9 prebuilts in the manifest aren't forks and are skipped.
#
# Usage: ./create-lineage-24.0-branches.sh [workspace-root] [remote]
#   workspace-root defaults to /home/rinando/android/system
#   remote          defaults to "github" (matches remote="github" in the manifest)

set -uo pipefail

# Run this script directly (./script.sh), don't `source` it — if sourced and
# something fails, `exit` below would close your entire terminal instead of
# just ending the script. This check keeps that from happening either way.
if (return 0 2>/dev/null); then
    sourced=1
else
    sourced=0
fi

bail() {
    echo "$1" >&2
    if [ "$sourced" -eq 1 ]; then
        return 1
    else
        exit 1
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${SCRIPT_DIR}/herolte-24.0.xml"
ROOT="${1:-/home/rinando/android/system}"
REMOTE="${2:-github}"
BRANCH="lineage-24.0"

if [ ! -f "$MANIFEST" ]; then
    bail "Manifest not found: $MANIFEST"
fi

if ! command -v xmllint >/dev/null 2>&1; then
    bail "xmllint is required but not installed"
fi

paths=$(xmllint --xpath '//project[starts-with(@name, "rinando/")]/@path' "$MANIFEST" | tr ' ' '\n' | sed -n 's/^path="\(.*\)"$/\1/p')

if [ -z "$paths" ]; then
    bail "No rinando/ <project path=...> entries found in $MANIFEST"
fi

fail=0
while IFS= read -r path; do
    repo_dir="${ROOT}/${path}"

    if [ ! -d "$repo_dir/.git" ]; then
        echo "SKIP  $path (not found at $repo_dir)"
        fail=1
        continue
    fi

    if git -C "$repo_dir" show-ref --verify --quiet "refs/heads/${BRANCH}"; then
        created=0
    else
        if ! checkout_err=$(git -C "$repo_dir" checkout -b "$BRANCH" 2>&1); then
            echo "FAIL  $path (git checkout -b failed: ${checkout_err})"
            fail=1
            continue
        fi
        created=1
    fi

    git -C "$repo_dir" config credential.helper store

    if push_err=$(git -C "$repo_dir" push -u "$REMOTE" "$BRANCH" 2>&1); then
        if [ "$created" -eq 1 ]; then
            echo "OK    $path -> created and pushed '${BRANCH}' to ${REMOTE}"
        else
            echo "OK    $path -> '${BRANCH}' already existed locally, pushed to ${REMOTE}"
        fi
    else
        echo "FAIL  $path (push to ${REMOTE} failed: ${push_err})"
        fail=1
    fi
done <<< "$paths"

if [ "$sourced" -eq 1 ]; then
    return "$fail"
else
    exit "$fail"
fi
