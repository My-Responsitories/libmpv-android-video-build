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
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="$OPT_FLAGS" \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON

make -j$cores VERBOSE=1
make CFLAGS="$OPT_CFLAGS" CXXFLAGS="$OPT_CXXFLAGS" DESTDIR="$prefix_dir" install
