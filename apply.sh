#!/bin/bash

PATCHESDIR="$PWD"
ANDROIDDIR="$PWD/.."

AOSPBRANCH="refs/tags/android-13.0.0_r43"
LOSBRANCH="github/lineage-20.0"

echo
echo "======= frameworks/native =========="
cd "$ANDROIDDIR/frameworks/native"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/frameworks_native/0001-Disable-gpu-service.patch"

echo
echo "======= frameworks/libs/net =========="
cd "$ANDROIDDIR/frameworks/libs/net"
git checkout $AOSPBRANCH
git am --signoff < "$PATCHESDIR/frameworks_libs_net/0001-Support-no-BPF-usecase.patch"


echo
echo "======= packages/modules/adb =========="
cd "$ANDROIDDIR/packages/modules/adb"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/packages_modules_adb/0001-adb-Bring-back-support-for-legacy-FunctionFS.patch"

echo
echo "======= system/bpf =========="
cd "$ANDROIDDIR/system/bpf"
git checkout $AOSPBRANCH
git am --signoff < "$PATCHESDIR/system_bpf/0001-Support-no-BPF-usecase.patch"

echo
echo "======= packages/modules/NetworkStack =========="
cd "$ANDROIDDIR/packages/modules/NetworkStack"
git checkout $AOSPBRANCH
git am --signoff < "$PATCHESDIR/packages_modules_NetworkStack/0001-Revert-Enable-parsing-netlink-events-from-kernel-sin.patch"

echo
echo "======= packages/modules/Connectivity =========="
cd "$ANDROIDDIR/packages/modules/Connectivity"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0001-Support-no-BPF-usecase.patch"

echo
echo "======= system/netd =========="
cd "$ANDROIDDIR/system/netd"
git checkout $AOSPBRANCH
git am --signoff < "$PATCHESDIR/system_netd/0001-Add-no-BPF-usecase-support.patch"

echo
echo "======= system/security =========="
cd "$ANDROIDDIR/system/security"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_security/0001-keystore-hackup.patch" 

echo
echo "======= system/core =========="
cd "$ANDROIDDIR/system/core"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_core/0001-Add-no-BPF-usecase-support.patch"

cd $PATCHESDIR

echo
echo "======= APPLY BATTERY LIFE EXTENDER PATCHES =========="
cd "features/batterylifeextender/"
. apply.sh

cd $PATCHESDIR

