#!/bin/bash

PATCHESDIR="$PWD"
ANDROIDDIR="$PWD/.."

AOSPBRANCH="refs/tags/android-14.0.0_r31"
LOSBRANCH="github/lineage-21.0"

echo "======= frameworks/base =========="
cd "$ANDROIDDIR/frameworks/base"
git am --abort
git add -A
git reset --hard
git checkout $LOSBRANCH

echo "======= frameworks/libs/net =========="
cd "$ANDROIDDIR/frameworks/libs/net"
git am --abort
git add -A
git reset --hard
git checkout $AOSPBRANCH

echo "======= packages/modules/adb =========="
cd "$ANDROIDDIR/packages/modules/adb"
git am --abort
git add -A
git reset --hard
git checkout $LOSBRANCH

echo "======= packages/modules/Connectivity =========="
cd "$ANDROIDDIR/packages/modules/Connectivity"
git am --abort
git add -A
git reset --hard
git checkout $LOSBRANCH

echo "======= packages/modules/NetworkStack =========="
cd "$ANDROIDDIR/packages/modules/NetworkStack"
git am --abort
git add -A
git reset --hard
git checkout $AOSPBRANCH

xxx
echo "======= system/bpf =========="
cd "$ANDROIDDIR/system/bpf"
git am --abort
git add -A
git reset --hard
git checkout $AOSPBRANCH

echo "======= system/core =========="
cd "$ANDROIDDIR/system/core"
git am --abort
git add -A
git reset --hard
git checkout $LOSBRANCH

echo "======= system/netd =========="
cd "$ANDROIDDIR/system/netd"
git am --abort
git add -A
git reset --hard
git checkout $AOSPBRANCH

echo "======= system/security =========="
cd "$ANDROIDDIR/system/security"
git am --abort
git add -A
git reset --hard
git checkout $LOSBRANCH

cd $PATCHESDIR
