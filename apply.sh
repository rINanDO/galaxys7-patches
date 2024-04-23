#!/bin/bash

PATCHESDIR="$PWD"
ANDROIDDIR="$PWD/.."

AOSPBRANCH="refs/tags/android-14.0.0_r31"
LOSBRANCH="github/lineage-21.0"

git am --signoff < ~/patches/build_make/0001-Ignore-linker-err.patch
echo
echo "======= build/make =========="
cd "$ANDROIDDIR/build/make"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/build_make/0001-Ignore-linker-err.patch"

echo
echo "======= frameworks/base =========="
cd "$ANDROIDDIR/frameworks/base"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/frameworks_base/0001-Revert-Revert-Treat-process-group-creation-failure-d.patch" 
git am --signoff < "$PATCHESDIR/frameworks_base/0002-Ignore-cgroup-creation-errors.patch"
git am --signoff < "$PATCHESDIR/frameworks_base/0003-Revert-CachedAppOptimizer-use-new-cgroup-api-for-fre.patch"
git am --signoff < "$PATCHESDIR/frameworks_base/0004-Revert-CachedAppOptimizer-remove-native-freezer-enab.patch"
git am --signoff < "$PATCHESDIR/frameworks_base/0005-Revert-CachedAppOptimizer-don-t-hardcode-freezer-pat.patch"
git am --signoff < "$PATCHESDIR/frameworks_base/0006-CachedAppOptimizer-revert-freezer-to-cgroups-v1.patch"

echo
echo "======= packages/modules/adb =========="
cd "$ANDROIDDIR/packages/modules/adb"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/packages_modules_adb/0001-adb-Bring-back-support-for-legacy-FunctionFS.patch"

echo
echo "======= packages/modules/Connectivity =========="
cd "$ANDROIDDIR/packages/modules/Connectivity"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0001-Allow-failing-to-load-bpf-programs-for-BPF-less-devi.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0002-Dont-delete-UID-from-BpfMap-on-BPF-less-kernel.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0006-Fix-null-pointer-crash-on-bpfless-devicess.patch"

echo
echo "======= system/bpf =========="
cd "$ANDROIDDIR/system/bpf"
git checkout $AOSPBRANCH
git am --signoff < "$PATCHESDIR/system_bpf/0001-Support-no-bpf-usecase.patch"

echo
echo "======= system/core =========="
cd "$ANDROIDDIR/system/core"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_core/0001-Fix-support-for-devices-without-cgroupv2-support.patch"
git am --signoff < "$PATCHESDIR/system_core/0002-reboot-must-be-fast-on-legacy-too.patch"
git am --signoff < "$PATCHESDIR/system_core/0003-Revert-libprocessgroup-switch-freezer-to-cgroup-v2.patch"

echo
echo "======= system/security =========="
cd "$ANDROIDDIR/system/security"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_security/0001-keystore-hackup.patch"

cd $PATCHESDIR

