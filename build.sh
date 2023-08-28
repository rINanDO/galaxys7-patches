#!/bin/bash
CURRENTDIR="$PWD"
BRANCH="v1-t" 

repo init -u https://gitlab.e.foundation/e/os/android.git -b v1-t --git-lfs
cd .repo/manifests
git checkout origin/v1-t
cd ../..
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

repo init -u https://gitlab.e.foundation/e/os/android.git -b $BRANCH --git-lfs
. roomservice.sh
repo sync --force-sync

cd $CURRENTDIR
. apply.sh
cd ../
. build/envsetup.sh
breakfast herolte
make clean && brunch herolte
