#!/bin/bash -e
unset CC CXX
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

VULKAN_CONFIG="-Dvulkan=disabled"
if [ -n "$ENABLE_VULKAN" ]; then
	VULKAN_CONFIG="-Dvk-proc-addr=enabled"
fi

NDK_WRAPPER_DISABLED=1 $_MESON \
	-Dauto_features=disabled \
	-Ddemos=false \
	-Dauto_features=disabled \
	$VULKAN_CONFIG

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install

# add missing library for static linking
# this isn't "-lstdc++" due to a meson bug: https://github.com/mesonbuild/meson/issues/11300
sed -i '/^Libs:/ s|$| -lc++|' "$TARGET_PREFIX_DIR/lib/pkgconfig/libplacebo.pc"
