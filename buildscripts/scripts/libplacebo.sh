#!/bin/bash -e
unset CC CXX

VULKAN_CONFIG="-Dvulkan=disabled"
if [ -n "$ENABLE_VULKAN" ]; then
	VULKAN_CONFIG="-Dvk-proc-addr=enabled"
fi

$_MESON \
	-Ddemos=false \
	-Dauto_features=disabled \
	$VULKAN_CONFIG

$_NINJA
DESTDIR="$prefix_dir" $_NINJA install

# add missing library for static linking
# this isn't "-lstdc++" due to a meson bug: https://github.com/mesonbuild/meson/issues/11300
sed -i '/^Libs:/ s|$| -lc++|' "$prefix_dir/lib/pkgconfig/libplacebo.pc"
