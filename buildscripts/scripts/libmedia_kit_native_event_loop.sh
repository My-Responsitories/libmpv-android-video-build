#!/usr/bin/env bash
set -euo pipefail

: "${DEPS_DIR:?DEPS_DIR is not set}"
: "${BUILD_DIR:?BUILD_DIR is not set}"
: "${TARGET_ABI:?TARGET_ABI is not set}"
: "${CXX:?CXX is not set}"
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

event_loop_src="$DEPS_DIR/media_kit/media_kit_native_event_loop/src/media_kit_native_event_loop.cc"
target_lib_dir="${TARGET_LIB_DIR:-$BUILD_DIR/output/lib/$TARGET_ABI}"
compat_include_root="$BUILD_DIR/output/include-compat/$TARGET_ABI"
mpv_include_root="$TARGET_PREFIX_DIR/include"
mpv_client_dir="$TARGET_PREFIX_DIR/include/mpv"
include_args=()

[[ -f "$event_loop_src" ]] || {
	echo "Missing source file: $event_loop_src" >&2
	exit 1
}

if [[ ! -f "$mpv_client_dir/client.h" ]]; then
	echo "Missing mpv header: $mpv_client_dir/client.h" >&2
	exit 1
fi

mkdir -p "$target_lib_dir"
mkdir -p "$compat_include_root"
# Some event-loop sources use #include "include/client.h".
ln -sfn "$mpv_client_dir" "$compat_include_root/include"
include_args+=("-I$mpv_include_root")
include_args+=("-I$compat_include_root")

"$CXX" "$event_loop_src" \
	-std=c++17 \
	-fPIC \
	-shared \
	-Wl,-z,max-page-size=16384 \
	"${include_args[@]}" \
	-L"$target_lib_dir" \
	-lmpv \
	-o "$target_lib_dir/libmedia_kit_native_event_loop.so"
