#!/bin/bash -e
unset CC CXX # meson wants these unset

NDK_WRAPPER_DISABLED=1 $_MESON \
	-Dauto_features=disabled \
	-Dmmap=auto

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
