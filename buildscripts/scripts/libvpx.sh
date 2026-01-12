#!/bin/bash -e
unset CC CXX # meson wants these unset

$_MESON \
	-Ddefault_library=static \
	-Dcpu_features_path="$ANDROID_NDK_LATEST_HOME/sources/android/cpufeatures"

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install
