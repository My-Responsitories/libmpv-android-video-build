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

CFLAGS="$OPT_CFLAGS" CXXFLAGS="$OPT_CXXFLAGS" meson setup $build --cross-file "$prefix_dir"/crossfile.txt --strip

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install
