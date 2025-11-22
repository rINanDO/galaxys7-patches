# LineageOS 22.2/Android 15 patches for Galaxy S7 (HeroLTE) support

These instructions assumes that:

- you have installed LineageOS 22.2 sources installed in ```~/android/system```
  (See <https://github.com/LineageOS/android/tree/lineage-22.2>)

  ```#!/bin/bash
  repo init -u <https://github.com/LineageOS/android.git> -b lineage-22.2 --git-lfs
  repo sync
  ```

- you have installed these patches to ```~/patches```

## 1. Apply device specific repo's

```#!/bin/bash
mkdir ~/android/system/.repo/local_manifests
cd ~/patches
cp roomservice.xml to ~/android/system/.repo/local_manifests
cd ~/android/system
repo sync
```  

## 2. Apply the patches

```#!/bin/bash
cd ~/android/system
. ~/patches/apply.sh
```

## 3. Optional, apply the "Battery Life Extender"-feature patches

```#!/bin/bash
cd ~/android/system
. ~/patches/features/batterylifeextender/apply.sh
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
. ~/patches/features/batterylifeextender/revert.sh
. ~/patches/revert.sh
```

Have fun!

These patches were last tested on:
22 nov 2025.
