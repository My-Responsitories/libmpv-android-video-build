#!/bin/bash -e
unset CC CXX # meson wants these unset
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

NDK_WRAPPER_DISABLED=1 $_MESON \
	-Dauto_features=disabled \
	-Dmmap=auto

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install
