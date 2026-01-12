#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
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

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install

ln -sf "$prefix_dir/lib/libmpv.so" "$native_dir"
