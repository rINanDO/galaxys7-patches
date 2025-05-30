#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["bionic"]="bionic"
    ["build/make"]="build_make"
    ["frameworks/av"]="frameworks_av"
    ["frameworks/base"]="frameworks_base"
    ["frameworks/native"]="frameworks_native"
    ["hardware/interfaces"]="hardware_interfaces"
    ["packages/modules/Connectivity"]="packages_modules_Connectivity"
    ["packages/modules/DnsResolver"]="packages_modules_DnsResolver"
    ["packages/modules/NetworkStack"]="packages_modules_NetworkStack"
    ["system/bpf"]="system_bpf"
    ["system/core"]="system_core"
    ["system/netd"]="system_netd"
    ["system/security"]="system_security"
    ["vendor/lineage"]="vendor_lineage"
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
