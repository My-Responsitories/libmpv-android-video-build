#!/bin/bash -e
mkdir -p $build_dir
pushd $build_dir

cmake .. \
	-DENABLE_SHARED=OFF \
	-DENABLE_STATIC=ON \
	-DENABLE_ENCRYPTION=ON \
	-DCMAKE_PREFIX_PATH="$prefix_dir" \
	-DUSE_ENCLIB=mbedtls \
	-DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \
	-DCMAKE_VERBOSE_MAKEFILE=ON

$_MAKE
DESTDIR="$prefix_dir" $_MAKE install

popd
