#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
