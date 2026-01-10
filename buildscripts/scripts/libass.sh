#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

[ -f configure ] || ./autogen.sh

mkdir -p _build$ndk_suffix
cd _build$ndk_suffix

../configure \
	CFLAGS="$OPT_CFLAGS" CXXFLAGS="$OPT_CXXFLAGS" \
	--host=$ndk_triple \
	--with-pic \
	--disable-asm \
	--enable-static\
	--disable-shared \
	--disable-require-system-font-provider

make -j$cores V=1
make DESTDIR="$prefix_dir" install
