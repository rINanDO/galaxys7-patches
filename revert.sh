#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["system/netd"]="system_netd"
    ["system/bpf"]="system_bpf"
    ["frameworks/base"]="frameworks_base"
    ["build/make"]="build_make"
    ["frameworks/native"]="frameworks_native"
    ["packages/modules/adb"]="packages_modules_adb"
    ["packages/modules/Connectivity"]="packages_modules_Connectivity"
    ["packages/modules/DnsResolver"]="packages_modules_DnsResolver"
    ["packages/modules/NetworkStack"]="packages_modules_NetworkStack"
    ["system/core"]="system_core"
    ["system/security"]="system_security"
)

# Base path for the patches
patches_base_path=~/patches

for dir in "${!patches[@]}"; do
    cd $dir || { echo "Directory $dir not found"; exit 1; }

    patch_dir=${patches[$dir]}
    patch_files=($patches_base_path/$patch_dir/*.patch)

    num_patches=${#patch_files[@]}

    if [ $num_patches -gt 0 ]; then
        git am --abort
	repo sync .
    fi

    cd - > /dev/null
done
