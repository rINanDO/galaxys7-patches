#!/bin/bash

PATCHESDIR="$PWD"
ANDROIDDIR="$PWD/../../.."

echo
echo "======= packages/apps/Settings =========="
cd "$ANDROIDDIR/packages/apps/Settings"
git am --signoff < "$PATCHESDIR/packages_apps_Settings/0001-Settings-add-Protect-battery-toggle.patch"

echo
echo "======= hardware/lineage/interfaces =========="
cd "$ANDROIDDIR/hardware/lineage/interfaces"
git checkout $LOSBRANCH
batterylifeextender-HAL.patch"

echo
echo "======= hardware/samsung =========="
cd "$ANDROIDDIR/hardware/samsung"
git am --signoff < "$PATCHESDIR/hardware_samsung/0001-hidl-add-batterylifeextender-implementation.patch"

echo
echo "======= device/lineage/sepolicy =========="
cd "$ANDROIDDIR/device/lineage/sepolicy"
git am --signoff < "$PATCHESDIR/device_lineage_sepolicy/0001-sepolicy-add-hal_lineage_batterylifeextender.patch"

echo
echo "======= device/samsung/universal8890-common =========="
cd "$ANDROIDDIR/device/samsung/universal8890-common"
git am --signoff < "$PATCHESDIR/device_samsung_universal8890-common/0001-universal8890-sepolicy-add-hal_lineage_batterylifeex.patch"
git am --signoff < "$PATCHESDIR/device_samsung_universal8890-common/0002-universal8890-build-batterylifeextender-HIDL.patch"
