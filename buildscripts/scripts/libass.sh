#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Dauto_features=disabled \
	-Dasm=enabled \
	-Drequire-system-font-provider=false \
	-Dlarge-tiles=true

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
