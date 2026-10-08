#!/usr/bin/env bash
set -euo pipefail

unset CC CXX # meson wants these unset

: "${BUILD_DIR:?BUILD_DIR is not set}"
: "${TARGET_ABI:?TARGET_ABI is not set}"
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

target_lib_dir="${TARGET_LIB_DIR:-$BUILD_DIR/output/lib/$TARGET_ABI}"

VULKAN_CONFIG="-Dvulkan=disabled"
if [[ -n "${ENABLE_VULKAN:-}" ]]; then
	VULKAN_CONFIG="-Dvulkan=enabled"
fi

NDK_WRAPPER_DISABLED=1 $_MESON \
	--prefer-static \
	--default-library=shared \
	-Dgpl=false \
	-Dcplayer=false \
	-Dbuild-date=false \
	-Diconv=disabled \
	-Dlua=disabled \
	-Dzlib=disabled \
	-Dcplugins=disabled \
	-Dmanpage-build=disabled \
	$VULKAN_CONFIG

$_NINJA
DESTDIR="$TARGET_PREFIX_DIR" $_NINJA install

mkdir -p "$target_lib_dir"
cp -f "$TARGET_PREFIX_DIR/lib/libmpv.so" "$target_lib_dir/libmpv.so"
