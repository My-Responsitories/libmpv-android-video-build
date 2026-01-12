#!/bin/bash -e
source ../../include/path.sh

unset CC CXX
$_MESON \
	-Dvulkan=disabled \
	-Ddemos=false

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install

# add missing library for static linking
# this isn't "-lstdc++" due to a meson bug: https://github.com/mesonbuild/meson/issues/11300
${SED:-sed} '/^Libs:/ s|$| -lc++|' "$prefix_dir/lib/pkgconfig/libplacebo.pc" -i
