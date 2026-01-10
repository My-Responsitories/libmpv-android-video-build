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

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--strip \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
	-Dbuild-date=false \
 	-Dlua=disabled \
 	-Dcplayer=false \
	-Diconv=disabled \
	-Dvulkan=disabled \
 	-Dmanpage-build=disabled

ninja -v -C $build -j$cores
DESTDIR="$prefix_dir" ninja -v -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
