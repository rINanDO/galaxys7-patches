#!/bin/bash

PATCHESDIR="$PWD"
ANDROIDDIR="$PWD/.."

AOSPBRANCH="refs/tags/android-14.0.0_r35"
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
echo "======= kernel/samsung/universal8890 =========="
cd "$ANDROIDDIR/kernel/samsung/universal8890"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/kernel_samsung_universal8890/0001-Revert-drivers-samsung-always-save-last_kmsg.patch" 
git am --signoff < "$PATCHESDIR/kernel_samsung_universal8890/0002-Revert-exynos_tmu-fix-compiling-with-EXYNOS_SNAPSHOT.patch"
git am --signoff < "$PATCHESDIR/kernel_samsung_universal8890/0003-Revert-kernel-Fix-compilation-after-disabling-tracin.patch"
git am --signoff < "$PATCHESDIR/kernel_samsung_universal8890/0004-Revert-kernel-Disable-tracing.patch"

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

git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0001-Allow-failing-to-load-bpf-programs-for-BPF-less-devi.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0002-Dont-delete-UID-from-BpfMap-on-BPF-less-kernel.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0003-Fix-null-pointer-crash-on-bpfless-devicess.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0004-Revert-remove-out-of-process-flag.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0005-Revert-Use-new-soong-support-to-install-privapp-xml.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0006-Fix-null-pointer-crash-on-bpfless-devicess.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0006-Revert-remove-inprocess-tethering.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0007-UL-mdns-disable-SocketNetlinkMonitor.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0008-Make-the-use-of-IBpfMaps-optional.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0009-Bring-back-traffic-indicators-for-legacy-devices.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0010-BpfNetMaps-check-if-map-is-null-to-prevent-crash-on-.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0011-Restore-back-the-behavior-of-isValid-It-is-legal-to-.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0012-UL-DNM-netbpfload-Disable-reboot-on-failure.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0013-UL-netbpfload-Support-no-bpf-usecase.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0014-UL-dnsresolver-Support-no-bpf-usecase.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0015-UL-clatcoordinator-Support-no-bpf-usecase.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0016-UL-BpfNetMaps-Make-use-of-BpfNetMaps-safe.patch"
git am --signoff < "$PATCHESDIR/packages_modules_Connectivity/0017-UL-libnetworkstats-Make-use-of-BpfMap-safe.patch" 

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

echo "======= system/netd =========="
cd "$ANDROIDDIR/system/netd"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_netd/0001-Don-t-fail-on-FTP-conntracking-failing.patch"
git am --signoff < "$PATCHESDIR/system_netd/0002-Support-no-bpf-usecase.patch"
git am --signoff < "$PATCHESDIR/system_netd/0003-Don-t-abort-in-case-of-cgroup-bpf-setup-fail-since-s.patch"

echo
echo "======= system/security =========="
cd "$ANDROIDDIR/system/security"
git checkout $LOSBRANCH
git am --signoff < "$PATCHESDIR/system_security/0001-keystore-hackup.patch"

cd $PATCHESDIR

