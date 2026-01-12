#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$_MESON \
	-Dtests=false \
	-Ddocs=false

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
