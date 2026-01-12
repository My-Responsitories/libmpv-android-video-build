#!/bin/bash -e
set -euo pipefail

PATCHES=($BUILDSCRIPTS_DIR/patches/*)

for dep_path in "${PATCHES[@]}"; do
    patches=($dep_path/*)
    dep=$(basename $dep_path)
    pushd deps/$dep
    echo Patching $dep
    git reset --hard
    for patch in "${patches[@]}"; do
        echo Applying $patch
        git apply $patch
    done
    popd
done

exit 0
