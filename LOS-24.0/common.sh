#!/usr/bin/env bash
#
# Shared configuration and helpers for the LOS-24.0 scripts and the
# features/*/ scripts. This file is sourced, not executed.

# ---------------------------------------------------------------------------
# Repositories carrying patches from this patch set.
#
# One entry per line: "<path in source tree>  <patch directory in LOS-24.0/>"
# Keep the list sorted by path. To track a new repo, add a line here and drop
# its `git format-patch` output into the matching patch directory.
# ---------------------------------------------------------------------------
PATCHED_REPOS=(
    "art                              art"
    "bionic                           bionic"
    "bootable/recovery                bootable_recovery"
    "build/make                       build_make"
    "build/soong                      build_soong"
    "external/perfetto                external_perfetto"
    "frameworks/av                    frameworks_av"
    "frameworks/base                  frameworks_base"
    "frameworks/hardware/interfaces   frameworks_hardware_interfaces"
    "frameworks/native                frameworks_native"
    "hardware/interfaces              hardware_interfaces"
    "hardware/libhardware_legacy      hardware_libhardware_legacy"
    "hardware/lineage/compat          hardware_lineage_compat"
    "hardware/lineage/interfaces      hardware_lineage_interfaces"
    "packages/modules/Connectivity    packages_modules_Connectivity"
    "packages/modules/DnsResolver     packages_modules_DnsResolver"
    "packages/modules/NetworkStack    packages_modules_NetworkStack"
    "prebuilts/build-tools            prebuilts_build-tools"
    "system/bpf                       system_bpf"
    "system/core                      system_core"
    "system/linkerconfig              system_linkerconfig"
    "system/memory/lmkd               system_memory_lmkd"
    "system/netd                      system_netd"
    "system/security                  system_security"
    "system/sepolicy                  system_sepolicy"
    "system/tools/hidl                system_tools_hidl"
    "system/tools/mkbootimg           system_tools_mkbootimg"
    "system/vold                      system_vold"
    "system/zygote                    system_zygote"
    "vendor/lineage                   vendor_lineage"
)

PATCHES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# Shown by apply.sh/revert.sh. A feature's scripts set their own PATCH_SET,
# PATCHES_DIR and PATCHED_REPOS after sourcing this file.
PATCH_SET="LOS-24.0 patches"

DEVICE="herolte"
LINEAGE_BRANCH="lineage-24.0"
LINEAGE_MANIFEST_URL="${LINEAGE_MANIFEST_URL:-https://github.com/LineageOS/android.git}"
LOCAL_MANIFEST="herolte-24.0.xml"

shopt -s nullglob

# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RESET=$'\e[0m' C_BOLD=$'\e[1m' C_DIM=$'\e[2m'
    C_RED=$'\e[31m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_BLUE=$'\e[34m'
else
    C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW='' C_BLUE=''
fi

die() {
    echo "${C_RED}error:${C_RESET} $*" >&2
    exit 1
}

header() {
    echo "${C_BOLD}${C_BLUE}==>${C_RESET}${C_BOLD} $*${C_RESET}"
}

warn() {
    echo "${C_YELLOW}warning:${C_RESET} $*" >&2
}

# Prints an indented, bulleted list of the remaining arguments under a title.
list() {
    local title=$1 item
    shift
    echo "    $title"
    for item in "$@"; do
        echo "      ${C_DIM}*${C_RESET} $item"
    done
}

# Asks a yes/no question; anything but y/yes is a no. Skipped when ASSUME_YES=1.
confirm() {
    local answer
    [ "${ASSUME_YES:-0}" -eq 1 ] && return 0
    read -r -p "$* [y/N] " answer
    [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]
}

# plural <count> <singular> [plural]: "1 commit" / "3 commits", "2 patches"
plural() {
    if [ "$1" -eq 1 ]; then echo "$1 $2"; else echo "$1 ${3:-${2}s}"; fi
}

# Prints the left half of a progress line, e.g. "[ 3/27] build/make ......"
# The line is completed by repo_ok / repo_skip / repo_fail.
repo_begin() {
    local index=$1 total=$2 path=$3
    local dots
    dots=$(printf '%*s' $((36 - ${#path})) '' | tr ' ' '.')
    printf '%s[%2d/%d]%s %s %s%s%s ' \
        "$C_DIM" "$index" "$total" "$C_RESET" "$path" "$C_DIM" "$dots" "$C_RESET"
}

repo_ok()   { echo "${C_GREEN}OK${C_RESET}    $*"; count_ok=$((count_ok + 1)); }
repo_skip() { echo "${C_YELLOW}SKIP${C_RESET}  $*"; count_skip=$((count_skip + 1)); }
repo_fail() {
    echo "${C_RED}FAIL${C_RESET}  $1"
    failed+=("$2")
}

# ---------------------------------------------------------------------------
# Common setup
# ---------------------------------------------------------------------------
count_ok=0
count_skip=0
failed=()

# resolve_source_root [source-root]
#   Sets SOURCE_ROOT (defaults to the current directory) and checks that it is
#   a repo checkout.
resolve_source_root() {
    SOURCE_ROOT="$(cd -- "${1:-$PWD}" 2>/dev/null && pwd)" \
        || die "source root not found: ${1:-$PWD}"
    [ -d "$SOURCE_ROOT/.repo" ] \
        || die "$SOURCE_ROOT is not a repo checkout (no .repo/). Run from the source root or pass it as the first argument."
}

require_tools() {
    local tool
    for tool in "$@"; do
        command -v "$tool" > /dev/null 2>&1 || die "'$tool' is required but not installed"
    done
}

# Prints the <project path> entries of a manifest file, one per line.
manifest_paths() {
    xmllint --xpath '//project/@path' "$1" 2>/dev/null \
        | tr ' ' '\n' | sed -n 's/^path="\(.*\)"$/\1/p'
}

# init <action-name> [source-root]
#   Resolves SOURCE_ROOT and creates LOG_DIR, where per-repo command output is
#   captured.
init() {
    local action=$1
    resolve_source_root "${2:-}"
    LOG_DIR="$(mktemp -d -t "herolte-${action}.XXXXXX")"

    header "${action^} $PATCH_SET"
    echo "    source root: $SOURCE_ROOT"
    echo "    patch set:   $PATCHES_DIR"
    echo
}

# Lists the .patch files for a patch directory, one per line, in order.
patch_files() {
    local f
    for f in "$PATCHES_DIR/$1"/*.patch; do
        echo "$f"
    done
}

am_in_progress() {
    (cd "$1" && [ -d "$(git rev-parse --git-path rebase-apply)" ])
}

# Path of the file capturing command output for a repo.
log_file() {
    echo "$LOG_DIR/${1//\//_}.log"
}

# Prints the result totals, points at the logs of failed repos and exits
# non-zero if anything failed. Logs are removed when everything succeeded.
finish() {
    local path
    echo
    header "Done: ${C_GREEN}${count_ok} ok${C_RESET}${C_BOLD}, ${C_YELLOW}${count_skip} skipped${C_RESET}${C_BOLD}, ${C_RED}${#failed[@]} failed${C_RESET}"
    if [ ${#failed[@]} -eq 0 ]; then
        rm -rf "$LOG_DIR"
        exit 0
    fi
    echo
    echo "Failed repositories (full output in $LOG_DIR):"
    for path in "${failed[@]}"; do
        if [ -s "$(log_file "$path")" ]; then
            echo "  ${C_RED}*${C_RESET} $path  ${C_DIM}->  $(log_file "$path")${C_RESET}"
        else
            echo "  ${C_RED}*${C_RESET} $path"
        fi
    done
    exit 1
}

# Applies the patches of every repo in PATCHED_REPOS with `git am --3way`. A
# repo whose patches don't apply is left in the middle of `git am`.
apply_patches() {
    local total=${#PATCHED_REPOS[@]} index=0 entry path patch_dir repo_dir log reason
    local -a patches
    for entry in "${PATCHED_REPOS[@]}"; do
        read -r path patch_dir <<< "$entry"
        index=$((index + 1))
        repo_dir="$SOURCE_ROOT/$path"
        log="$(log_file "$path")"

        repo_begin "$index" "$total" "$path"

        if [ ! -d "$repo_dir" ]; then
            repo_fail "directory not found" "$path"
            continue
        fi

        mapfile -t patches < <(patch_files "$patch_dir")
        if [ ${#patches[@]} -eq 0 ]; then
            repo_skip "no patches in $patch_dir/"
            continue
        fi

        if am_in_progress "$repo_dir"; then
            repo_fail "a previous git am is still in progress (run revert.sh first)" "$path"
            continue
        fi

        if git -C "$repo_dir" am --3way "${patches[@]}" > "$log" 2>&1; then
            repo_ok "$(plural ${#patches[@]} patch patches) applied"
        else
            reason=$(grep -m1 '^Patch failed at' "$log")
            repo_fail "${reason:-git am failed}" "$path"
        fi
    done
}

# Aborts any unfinished `git am` in every repo in PATCHED_REPOS and resets it
# to its manifest revision with `repo sync`.
revert_patches() {
    local total=${#PATCHED_REPOS[@]} index=0 entry path patch_dir repo_dir log note
    local -a patches
    for entry in "${PATCHED_REPOS[@]}"; do
        read -r path patch_dir <<< "$entry"
        index=$((index + 1))
        repo_dir="$SOURCE_ROOT/$path"
        log="$(log_file "$path")"

        repo_begin "$index" "$total" "$path"

        if [ ! -d "$repo_dir" ]; then
            repo_fail "directory not found" "$path"
            continue
        fi

        mapfile -t patches < <(patch_files "$patch_dir")
        if [ ${#patches[@]} -eq 0 ]; then
            repo_skip "no patches in $patch_dir/"
            continue
        fi

        note=""
        if am_in_progress "$repo_dir"; then
            git -C "$repo_dir" am --abort > "$log" 2>&1
            note=" (aborted unfinished git am)"
        fi

        if (cd "$repo_dir" && repo sync .) >> "$log" 2>&1; then
            repo_ok "synced$note"
        else
            repo_fail "repo sync failed$note" "$path"
        fi
    done
}
