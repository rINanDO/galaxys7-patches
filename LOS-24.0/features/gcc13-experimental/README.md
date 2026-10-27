# Experimental: build the herolte kernel with host GCC 13.3

These patches build the Linux 3.18 `universal8890` kernel with the build
host's GCC 13.3 cross-compilers instead of the GCC 4.9 prebuilts that
`herolte-24.0.xml` adds back (LineageOS 24.0 no longer ships a prebuilt
GCC, and this kernel predates clang-built-linux support).

This is **experimental**. With 0001-0007, a GCC 13 kernel boots, unlocks
and plays audio on herolte (tested 2026-10-18), but it has had much less
testing than the GCC 4.9 kernel. Keeping these changes separate
from the main LOS-24.0 patches makes it easier to rule the toolchain
in or out as the cause of boot problems.

## Requirements

```#!/bin/bash
sudo apt-get install -y gcc-aarch64-linux-gnu gcc-arm-linux-gnueabi
```

`gcc-arm-linux-gnueabi` builds the kernel's 32-bit compat vDSO
(`CROSS_COMPILE_ARM32`), which needs a real GCC.

## Apply

Apply the LOS-24.0 patches first, then:

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/features/gcc13-experimental/apply.sh
```

`../../setup.sh --gcc13` does both in one go.

## Revert

```bash
cd ~/android/system
patches/galaxys7-patches/LOS-24.0/features/gcc13-experimental/revert.sh
```

## Contents

| Repo | Patch | Purpose |
|---|---|---|
| kernel/samsung/universal8890 | 0001 arm64: spinlock | Register operand instead of `"I"` immediate for the ticket increment |
| | 0002 arm64: thread_info | Inline-asm `current_stack_pointer` instead of a global register variable |
| | 0003 arm64: mm: proc | `"ax"` section flags instead of `#alloc, #execinstr` |
| | 0004 Makefile | Probe for `-gcc-toolchain` instead of always passing it |
| | 0005 arm64: vdso32 | Filter `-Qunused-arguments` from the GCC-built compat vDSO flags |
| | 0006 herolte_defconfig | Disable `CONFIG_CRYPTO_FIPS` |
| | 0007 dmaengine: pl330 | Volatile byte stores for the audio DMAC microcode buffer (ioremapped SRAM); GCC 7+ store merging otherwise makes misaligned stores that panic the kernel on the first sound |
| device/samsung/universal8890-common | 0001 BoardConfigCommon | `TARGET_KERNEL_CROSS_COMPILE_PREFIX := /usr/bin/aarch64-linux-gnu-`, plus `KERNEL_CC` setting `CROSS_COMPILE_ARM32`/`CROSS_COMPILE_COMPAT` to `/usr/bin/arm-linux-gnueabi-` for the compat vDSO. `KERNEL_CC` comes last on the kernel make line, so it overrides the prebuilt GCC 4.9 |

The `vendor/lineage` GCC support this needs (the revert of "kernel: Rip
out GCC support") is part of `galaxys7-patches/LOS-24.0`, so there's no
`vendor/lineage` patch here.
