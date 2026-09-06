#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Dauto_features=disabled \
	-Draster=disabled \
	-Dvector=disabled \
	-Dsubset=disabled \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dutilities=disabled

NDK_WRAPPER_APPEND="$NDK_WRAPPER_APPEND -Oz" $_NINJA
DESTDIR="$prefix_dir" $_NINJA install
