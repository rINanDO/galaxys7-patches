#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["device/lineage/sepolicy"]="device_lineage_sepolicy"
    ["device/samsung/universal8890-common"]="device_samsung_universal8890-common"
    ["hardware/lineage/interfaces"]="hardware_lineage_interfaces"
    ["hardware/samsung"]="hardware_samsung"
    ["packages/apps/Settings"]="packages_apps_Settings"
    ["vendor/lineage"]="vendor_lineage"
)

# Base path for the patches
patches_base_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
