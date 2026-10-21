#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["art"]="art"
    ["bionic"]="bionic"
    ["bootable/recovery"]="bootable_recovery"
    ["build/make"]="build_make"
    ["build/soong"]="build_soong"
    ["external/perfetto"]="external_perfetto"
    ["frameworks/av"]="frameworks_av"
    ["frameworks/base"]="frameworks_base"
    ["frameworks/native"]="frameworks_native"
    ["frameworks/hardware/interfaces"]="frameworks_hardware_interfaces"
    ["hardware/interfaces"]="hardware_interfaces"
    ["hardware/libhardware_legacy"]="hardware_libhardware_legacy"
    ["hardware/lineage/compat"]="hardware_lineage_compat"
    ["hardware/lineage/interfaces"]="hardware_lineage_interfaces"
    ["packages/modules/Connectivity"]="packages_modules_Connectivity"
    ["packages/modules/DnsResolver"]="packages_modules_DnsResolver"
    ["packages/modules/NetworkStack"]="packages_modules_NetworkStack"
    ["prebuilts/build-tools"]="prebuilts_build-tools"
    ["system/bpf"]="system_bpf"
    ["system/core"]="system_core"
    ["system/linkerconfig"]="system_linkerconfig"
    ["system/memory/lmkd"]="system_memory_lmkd"
    ["system/netd"]="system_netd"
    ["system/security"]="system_security"
    ["system/sepolicy"]="system_sepolicy"
    ["system/tools/hidl"]="system_tools_hidl"
    ["system/tools/mkbootimg"]="system_tools_mkbootimg"
    ["system/vold"]="system_vold"
    ["system/zygote"]="system_zygote"
    ["vendor/lineage"]="vendor_lineage"
)

# Base path for the patches
patches_base_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

for dir in "${!patches[@]}"; do
    cd $dir || { echo "Directory $dir not found"; break; }

    patch_dir=${patches[$dir]}
    patch_files=($patches_base_path/$patch_dir/*.patch)

    for patch_file in "${patch_files[@]}"; do
        git am --3way < "$patch_file"
    done

    cd - > /dev/null
done
