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

    num_patches=${#patch_files[@]}

    if [ $num_patches -gt 0 ]; then
        git am --abort 2>/dev/null
        # Drop only the applied commits; --keep refuses rather than
        # discarding unrelated uncommitted work in these repos
        git reset --keep HEAD~$num_patches
    fi

    cd - > /dev/null
done
