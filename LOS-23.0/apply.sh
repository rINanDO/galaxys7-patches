#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["build/make"]="build_make"
    ["build/soong"]="build_soong"
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
    ["system/tools/mkbootimg"]="system_tools_mkbootimg"
)

# Base path for the patches
patches_base_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for dir in "${!patches[@]}"; do
    cd $dir || { echo "Directory $dir not found"; exit 1; }

    patch_dir=${patches[$dir]}
    patch_files=($patches_base_path/$patch_dir/*.patch)

    for patch_file in "${patch_files[@]}"; do
        git am --3way < "$patch_file"
    done

    cd - > /dev/null
done
