#!/bin/bash -e
mkdir -p $build_dir
pushd $build_dir

cmake .. \
	-DENABLE_TESTING=OFF \
	-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON

$_MAKE
DESTDIR="$prefix_dir" $_MAKE install

popd
