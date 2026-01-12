#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$_MESON \
	-Denable_tests=false \
	-Dstack_alignment=16

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
