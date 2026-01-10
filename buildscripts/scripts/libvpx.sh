#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf $build
	exit 0
else
	exit 255
fi

unset CC CXX # meson wants these unset

meson setup $build --cross-file "$prefix_dir"/crossfile.txt -Ddefault_library=static -Dcpu_features_path="$ANDROID_HOME/ndk/$v_ndk/sources/android/cpufeatures"

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install
