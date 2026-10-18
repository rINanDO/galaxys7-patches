#!/bin/bash

# Array of directories and corresponding patches
declare -A patches=(
    ["device/samsung/universal8890-common"]="device_samsung_universal8890-common"
    ["kernel/samsung/universal8890"]="kernel_samsung_universal8890"
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
