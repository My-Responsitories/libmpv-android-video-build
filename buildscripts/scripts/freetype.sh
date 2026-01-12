#!/bin/bash -e
source ../../include/path.sh

unset CC CXX # meson wants these unset

$_MESON

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
