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

$0 clean # separate building not supported, always clean

mkdir -p $build
cd $build

cmake .. \
	-DENABLE_TESTING=OFF \
	-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON

make -j$cores
make CFLAGS=-fPIC CXXFLAGS=-fPIC DESTDIR="$prefix_dir" install
