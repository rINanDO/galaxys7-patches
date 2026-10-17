# LineageOS 24.0/Android 17 patches for Galaxy S7 (HeroLTE) support

These instructions assume that:

- you have LineageOS 24.0 sources installed in ```~/android/system```
  (See <https://github.com/LineageOS/android/tree/lineage-24.0>)

  ```#!/bin/bash
  repo init -u <https://github.com/LineageOS/android.git> -b lineage-24.0 --git-lfs
  repo sync
  ```

- you have cloned this repository in ```~/patches```

- you have a 32-bit ARM GCC cross-compiler installed on the host. HeroLTE's
  arm64 kernel builds a 32-bit compat vDSO (`TARGET_2ND_ARCH := arm`), and
  the kernel's own `arch/arm64/Makefile` hard-requires a real
  `CROSS_COMPILE_ARM32`-prefixed GCC binary for this step - Clang cannot
  substitute for it, unlike the rest of the (Clang-only) LineageOS 24.0
  host toolchain:

  ```#!/bin/bash
  sudo apt-get install -y gcc-arm-linux-gnueabi
  ```

## 1. Apply device specific repo's

```#!/bin/bash
mkdir ~/android/system/.repo/local_manifests
cp ~/patches/LOS-24.0/herolte-24.0.xml ~/android/system/.repo/local_manifests/
cd ~/android/system
repo sync
```

## 2. Apply the patches

```#!/bin/bash
cd ~/android/system
. ~/patches/LOS-24.0/apply.sh
```

## 3. Optional, apply the "Battery Life Extender"-feature patches

```#!/bin/bash
cd ~/android/system
. ~/patches/LOS-24.0/features/batterylifeextender/apply.sh
```

## 4. Build the ROM

```#!/bin/bash
cd ~/android/system
. build/envsetup.sh
brunch herolte
```

Your build will be put (after many hours) in:

```~/android/system/out/target/product/herolte```

## How to revert the patches

```#!/bin/bash
cd ~/android/system
. ~/patches/LOS-24.0/features/batterylifeextender/revert.sh
. ~/patches/LOS-24.0/revert.sh
```

## What these patches address

HeroLTE (Galaxy S7, exynos8890) is, like the Tab S2 (gts210wifi,
exynos5433), a "legacy" device: an old, no-longer-updated 3.x/4.x kernel,
partial (or no) Treble, and closed-source vendor blobs that were never
built against anything newer than Android 9-10. A straight `repo sync` to
LineageOS 24.0 builds against current AOSP, which has spent several
releases actively removing exactly the compatibility shims these devices
still depend on. The patches below restore or re-add what's needed,
grouped by the underlying problem rather than by which repo they happen to
live in:

- **No-BPF kernel support** (`system_bpf`, `system_netd`,
  `packages_modules_Connectivity`, `packages_modules_DnsResolver`): modern
  Android assumes the kernel supports eBPF for network stats, traffic
  policing, and the no-longer-optional netd/NetBpfLoader stack. This
  device's kernel predates BPF entirely, so these teach the loader,
  netd, DnsResolver and the Connectivity module to degrade gracefully
  (skip BPF-backed stats, don't abort on missing cgroup v2/BPF
  directories) instead of crashing or failing to boot. This is the same
  class of fix gts210wifi needed, and was reused directly here since it's
  the identical upstream `system/bpf` et al. code.
- **cgroup v1-only kernel** (`system_core`, `frameworks_base`): the kernel
  predates cgroup v2 (`libprocessgroup`'s default since recent AOSP), so
  these revert the v2-only switch and make cgroup/process-group creation
  failures non-fatal instead of refusing to boot.
- **Pre-5.11 kernel syscalls** (`bionic`, `art`, `external_perfetto`,
  `frameworks_native`): `memfd_create()` version checks, `epoll_pwait2`
  (added in Linux 5.11, returns `ENOSYS` on this kernel and breaks
  `BLASTBufferQueue` buffer release otherwise), and `MADV_WIPEONFORK` are
  all assumed present by current AOSP; this kernel predates all of them.
- **No/partial Treble** (`system_linkerconfig`, `vendor/lineage`): recent
  AOSP made Treble mandatory and removed the legacy linker-namespace
  config path entirely (`PRODUCT_FULL_TREBLE` is now an obsolete,
  ignored variable - see `build/make/core/main.mk`). `system_linkerconfig`
  restores the pre-Treble linker configuration generator that this device
  still needs; `vendor/lineage`'s board-config fixes keep the
  device/kernel build config (including pre-clang kernel build flags)
  from being silently dropped by newer `lineage_generator`/Soong
  defaults.
- **Legacy (non-Treble) HIDL HALs** (`hardware_lineage_interfaces`,
  `hardware_libhardware_legacy`, `hardware_interfaces`): wifi, GNSS,
  health and power on this device are all pre-Treble legacy
  passthrough HIDL HALs that AOSP has since "sunset" (removed) in favor
  of AIDL/newer HIDL versions this hardware was never built to speak.
  These revert those removals/HAL version bumps and fix build breaks in
  the legacy HAL glue (including HeroLTE-specific fixes: a
  `universal8890-common` `wifi_hal.h` patch and a linker-error fix for
  the legacy `/vendor/bin/hw/rild`).
- **Build-system/compiler strictness** (`build_make`, `build_soong`,
  `bootable_recovery`, `system/vold`, `prebuilts_build-tools`): newer
  Clang/Kati/Soong reject things older vendor code and prebuilts relied
  on - a stricter `link_type_error` is downgraded back to a warning,
  missing `<vector>`/`<algorithm>` standard-library includes are added
  where modern headers no longer pull them in transitively, and an older
  `xz` version is restored because the current one broke this device's
  kernel build.
- **Misc stability/compat fixes** (`hardware_lineage_compat`,
  `system_memory_lmkd`, `system_security`, `frameworks_base`,
  `frameworks_native`): a null-pointer crash in the legacy `libsensor`
  compat shim, `lmkd` parsing assumptions that don't hold on this
  kernel's `/proc` layout, a keystore compatibility fix, GPU service
  disabled outright (this device's GPU driver stack predates
  `gpuservice`/BPF-backed GPU memory accounting), and SurfaceFlinger's
  HWC backpressure handling made runtime-toggleable instead of assumed.

- **Clang-only host toolchain vs. the kernel's 32-bit compat vDSO**
  (`device/samsung/universal8890-common`): LineageOS 24.0's host build
  toolchain is Clang-only (no `gcc` binary ships in the tree anymore), so
  `BoardConfigCommon.mk` points the kernel's host-tool compilation
  (`HOSTCC`/`HOSTCXX`) at Clang. That alone isn't enough, though: this is
  an arm64 kernel with 32-bit app compat (`TARGET_2ND_ARCH := arm`), and
  its `arch/arm64/Makefile` separately hard-requires a real
  `CROSS_COMPILE_ARM32`-prefixed GCC binary to build the 32-bit compat
  vDSO - Clang cannot satisfy that check. Install `gcc-arm-linux-gnueabi`
  on the host (see prerequisites above) before building.

**Explicitly not needed:** unlike gts210wifi, HeroLTE does not use the
legacy Camera HAL v1 and does not carry (or need) any of the Camera
HALv1/`camera2.legacy` restoration patches that gts210wifi's
`frameworks_av`/`frameworks_base` patch sets are mostly made of - only
HeroLTE's own small, unrelated `frameworks_av` patch (a custom
`CameraParameter` loader) applies here.

Have fun!

These patches were last tested on:
15 oct 2026.
