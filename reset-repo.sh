#!/bin/bash
CURRENTDIR="$PWD"
BRANCH="lineage-20.0" 

# Reset all existing repo's
cd ..
repo forall -c git am --abort
repo forall -c git reset --hard

rm -rf .repo/local_manifests

# (Re)initialize LineageOS 20.0 manifest
repo init -u https://github.com/LineageOS/android.git -b $BRANCH --git-lfs
cd .repo/manifests
git checkout origin/lineage-20.0
cd ../..
repo init -u https://github.com/LineageOS/android.git -b $BRANCH --git-lfs

rm -rf prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/*
rm -rf .repo/projects/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9.git

rm -rf hardware/samsung
rm -rf .repo/projects/hardware/samsung.git

rm -rf vendor/samsung
rm -rf .repo/projects/vendor/samsung.git

repo sync
