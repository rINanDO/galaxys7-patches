#!/bin/bash
CURRENTDIR="$PWD"
BRANCH="lineage-20.0" 

cd ..

repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
cd .repo/manifests
git checkout origin/lineage-20.0
cd ../..

repo forall -c git am --abort
repo forall -c git reset --hard

rm -rf android
rm -rf .repo/projects/android.git

rm -rf frameworks/libs/net
rm -rf .repo/projects/frameworks/libs/net.git

rm -rf packages/apps/ImsServiceEntitlement
rm -rf .repo/projects/packages/apps/ImsServiceEntitlement.git

rm -rf packages/apps/Updater
rm -rf .repo/projects/packages/apps/Updater.git

rm -rf packages/modules/DnsResolver
rm -rf .repo/projects/packages/modules/DnsResolver.git

rm -rf art
rm -rf android
rm -rf bionic
rm -rf bootable
rm -rf build
rm -rf cts
rm -rf dalvik
rm -rf developers
rm -rf development
rm -rf device
rm -rf external
rm -rf frameworks
rm -rf hardware
rm -rf kernel
rm -rf libcore
rm -rf libnativehelper
rm -rf lineage
rm -rf lineage-sdk
rm -rf packages
rm -rf pdk
rm -rf platform_testing
rm -rf prebuilts
rm -rf sdk
rm -rf system
rm -rf test
rm -rf toolchain
rm -rf tools
rm -rf vendor

repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs

cd $CURRENTDIR
. roomservice.sh
repo sync --force-sync
. apply.sh
cd ../
. build/envsetup.sh
breakfast herolte
make clean && brunch herolte
