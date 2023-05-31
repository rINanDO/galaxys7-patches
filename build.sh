#!/bin/bash
. roomservice.sh
repo sync --force-sync
. apply.sh
cd ../
. build/envsetup.sh
breakfast herolte
make clean && brunch herolte
