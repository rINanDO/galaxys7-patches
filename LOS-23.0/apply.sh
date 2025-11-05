#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["bionic"]="bionic" # OK Fixed LD_SHIM_LIBS 
    ["build/make"]="build_make" #OK
    ["frameworks/av"]="frameworks_av" #OK
    ["frameworks/base"]="frameworks_base" #OK
    ["frameworks/native"]="frameworks_native" #OK
    ["hardware/interfaces"]="hardware_interfaces" #OK
    ["packages/modules/Connectivity"]="packages_modules_Connectivity" # fixed
    ["packages/modules/DnsResolver"]="packages_modules_DnsResolver" #OK
    ["packages/modules/NetworkStack"]="packages_modules_NetworkStack" # Fixed
    ["system/bpf"]="system_bpf" #OK
    ["system/core"]="system_core" #Fixed
    ["system/netd"]="system_netd" #OK
    ["system/security"]="system_security" #OK
    ["vendor/lineage"]="vendor_lineage" # OK Fixed LD_SHIM_LIBS 

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
