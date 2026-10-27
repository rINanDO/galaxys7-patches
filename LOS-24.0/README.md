# LineageOS 24.0/Android 17 patches for Galaxy S7 (HeroLTE) support

These instructions assume that:

- the LineageOS 24.0 sources live (or will live) in `~/android/system`
  (see <https://github.com/LineageOS/android/tree/lineage-24.0>)
- this repository is cloned in `~/android/system/patches/galaxys7-patches`
- `git`, `git-lfs`, `repo` and `xmllint` are installed, plus the usual
  LineageOS build dependencies

All scripts accept the source root as their last argument and default to the
current directory. Run them directly (`./setup.sh`); sourcing them
(`. setup.sh`) also works.

## Quick start: set up everything

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/setup.sh
```

`setup.sh` does the whole job and can be re-run at any time:

1. `repo init -b lineage-24.0 --git-lfs` if the directory isn't a checkout yet
2. `cleanup.sh`: removes local manifests of other devices and drops any
   previously applied patches (herolte's or another device's)
3. installs `herolte-24.0.xml` into `.repo/local_manifests/`
4. `repo sync -d --force-sync`
5. `apply.sh`
6. with `--gcc13`: `features/gcc13-experimental/apply.sh`

Options: `-y` (don't ask for confirmation), `--force` (see
[Cleaning up](#cleaning-up)), `-j N` (parallel sync jobs), `--gcc13` (also
apply the experimental GCC 13 kernel patches).

## Build the ROM

```bash
cd ~/android/system
. build/envsetup.sh
brunch herolte
```

Your build will be put (after many hours) in:

`~/android/system/out/target/product/herolte`

## Cleaning up

To return the tree to plain LineageOS 24.0, without any local manifest or
patches:

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/cleanup.sh
```

This works on the whole tree, whichever device it was set up for. It lists
what it is going to do and asks before doing it:

- local manifests are moved to `.repo/local_manifests.backup/<date>/`
- unfinished `git am`/rebase/cherry-pick operations are aborted
- local commits (applied patches) are dropped and every project is synced to
  its manifest revision; add `--fetch` to also fetch updates from the network

It refuses to continue when a project has uncommitted changes, or when a
device repo has commits that aren't pushed to any remote. Commit/push or stash
that work first, or pass `--force` to throw it away.

## Applying or reverting only the patches

When the local manifest is already installed and synced:

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/apply.sh
patches/galaxys7-patches/LOS-24.0/revert.sh
```

A repo whose patches don't apply is left in the middle of `git am` so it can
be resolved by hand; the output points at a log with the details. `revert.sh`
aborts that and resets the patched repos with `repo sync`.

## Optional, experimental: build the kernel with host GCC 13

See [features/gcc13-experimental/README.md](features/gcc13-experimental/README.md)
for the requirements. Apply the LOS-24.0 patches first (or use
`setup.sh --gcc13`):

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/features/gcc13-experimental/apply.sh
patches/galaxys7-patches/LOS-24.0/features/gcc13-experimental/revert.sh
```

## Maintaining the patch set

- The patched repositories are listed once, in `common.sh` (`PATCHED_REPOS`).
  To track a new repo, add a line there and put its `git format-patch` output
  in the matching directory. A feature's repositories are listed in its own
  `apply.sh`/`revert.sh`.
- Device, kernel, hardware and vendor repos are forks, listed in
  `herolte-24.0.xml`. `create-lineage-24.0-branches.sh` creates and pushes
  the `lineage-24.0` branch in each `rinando/` repo.

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
- **cgroup v1-only kernel** (`system_core`, `frameworks_base`,
  `system_zygote`): the kernel predates cgroup v2 (`libprocessgroup`'s
  default since recent AOSP), so these revert the v2-only switch and make
  cgroup/process-group creation failures non-fatal instead of refusing to
  boot. `system_zygote` does the same for Android 17's Rust `zygote_next`
  and also skips capabilities newer than the kernel (`PR_CAPBSET_READ`
  returns EINVAL past `CAP_AUDIT_READ` on 3.18) when dropping the bounding
  set, like the Java zygote. Without it every native-only sandboxed process
  (Chrome/WebView) aborts: Chrome can't load pages and all app launches stall
  for about 90 s while system_server retries. It also logs Rust panics to
  logcat, since `zygote_next`'s stderr goes to /dev/null.
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
  still needs; `vendor/lineage`'s generator fix keeps the device
  build config from being silently dropped by newer
  `lineage_generator`/Soong defaults.
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

- **No PSI, cgroup v1 only** (`system_memory_lmkd`, `system_core`): AOSP
  now requires PSI (Linux 4.20+) in `lmkd`, but this 3.18 kernel has
  neither PSI nor the in-kernel lowmemorykiller, so `lmkd` exits at once
  and `system_server` deadlocks waiting for it ("Process system isn't
  responding"). `system_memory_lmkd` reverts `lmkd: Require PSI, remove
  support for vmpressure` so `lmkd` falls back to memcg vmpressure.
  It also reverts `Remove pidfd_supported check`, because 3.18 has no
  `pidfd_open` and every process registration failed, and stops
  requiring `RssAnon` (Linux 4.5+) in `/proc/<pid>/status`, which made
  `lmkd` skip every kill candidate.
  `system_core` also retries the cpuset cgroup mount without
  `cpuset_v2_mode` (Linux 4.17+), which this kernel rejects.
- **ION** (`system_sepolicy`): the camera, gralloc, hwcomposer and codec
  blobs still allocate their buffers through `/dev/ion`. AOSP removed all
  ION sepolicy, which leaves `/dev/ion` with the generic `device` label so
  every ION user is denied once SELinux is enforcing. `system_sepolicy`
  reverts `Remove ION sepolicy`. The camera also needs the real `libion`
  implementation, which the device tree enables with
  `$(call soong_config_set_bool,libion,legacy_impl,true)`, next to
  `$(call soong_config_set_bool,libui,legacy_gralloc,true)` for the
  gralloc 2.x mapper.
- **GCC 4.9 kernel toolchain** (`vendor_lineage`, `herolte-24.0.xml`):
  LineageOS 24.0 dropped the prebuilt GCC 4.9 toolchains from its
  manifest and removed GCC support from its kernel build
  (`kernel: Rip out GCC support`). This Linux 3.18 kernel predates
  clang-built-linux support and is built with GCC 4.9, the same
  compiler as in LineageOS 23.x. `herolte-24.0.xml` syncs
  `LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9`
  and `..._arm_arm-linux-androideabi-4.9` (branch `lineage-19.1`; the arm
  one builds the 32-bit compat vDSO), and `vendor_lineage` reverts the
  GCC removal. Building the kernel with the host's GCC 13 instead is
  kept separately in `features/gcc13-experimental`.

**Explicitly not needed:** unlike gts210wifi, HeroLTE does not use the
legacy Camera HAL v1 and does not carry (or need) any of the Camera
HALv1/`camera2.legacy` restoration patches that gts210wifi's
`frameworks_av`/`frameworks_base` patch sets are mostly made of - only
HeroLTE's own small, unrelated `frameworks_av` patch (a custom
`CameraParameter` loader) applies here.

Have fun!

These patches were last tested on:
15 oct 2026.
