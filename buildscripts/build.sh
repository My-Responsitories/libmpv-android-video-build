#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"
source "$BUILDSCRIPTS_DIR/include/depinfo.sh"

declare -A BUILT_TARGETS=()
declare -A ACTIVE_TARGETS=()

archs=(armv7l arm64 x86_64)

prepare_workspace() {
	rm -rf "$PREFIX_DIR" "$BUILD_DIR/output"
	ensure_dir "$DEPS_DIR" "$PREFIX_DIR"
}

prepare_dependencies() {
	"$BUILDSCRIPTS_DIR/download.sh"
	"$BUILDSCRIPTS_DIR/patch.sh"
	"$BUILDSCRIPTS_DIR/setup_wrapper.sh"
}

load_arch() {
	unset CC CXX CPATH LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH

	local api_level="${ANDROID_API_LEVEL:-24}"

	local cc_triple target_abi
	if [ "$1" == "armv7l" ]; then
		export ndk_suffix=
		export ndk_triple=arm-linux-androideabi
		cc_triple=armv7a-linux-androideabi$api_level
		target_abi=armeabi-v7a
		export NDK_WRAPPER_APPEND=
		elif [ "$1" == "arm64" ]; then
		export ndk_suffix=-arm64
		export ndk_triple=aarch64-linux-android
		cc_triple=$ndk_triple$api_level
		target_abi=arm64-v8a
		export NDK_WRAPPER_APPEND="-mcpu=cortex-a75+crypto -mtune=cortex-a55"
		elif [ "$1" == "x86_64" ]; then
		export ndk_suffix=-x64
		export ndk_triple=x86_64-linux-android
		cc_triple=$ndk_triple$api_level
		target_abi=x86_64
		export NDK_WRAPPER_APPEND=
	else
		echo "Invalid architecture"
		exit 1
	fi

	export build_dir="_build${ndk_suffix}"
	export TARGET_PREFIX_DIR="${PREFIX_DIR}/${target_abi}"
	export TARGET_ABI="$target_abi"
	export TARGET_LIB_DIR="$BUILD_DIR/output/lib/$TARGET_ABI"

	export CC="${cc_triple}-clang"
	export CXX="${cc_triple}-clang++"
	export AS="$CC"
	export AR="llvm-ar"
	export NM="llvm-nm"
	export RANLIB="llvm-ranlib"

	export _CMAKE="cmake -B $build_dir -S . -G Ninja -DCMAKE_INSTALL_PREFIX=$TARGET_PREFIX_DIR -DCMAKE_BUILD_TYPE=Release"
	export _MESON="meson setup $build_dir --cross-file $TARGET_PREFIX_DIR/crossfile.txt"
	export _MAKE="make -j$(nproc)"
	export _NINJA="ninja -j$(nproc) -C $build_dir"

	export PKG_CONFIG_SYSROOT_DIR="$TARGET_PREFIX_DIR"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
}

setup_prefix() {
	ensure_dir "$TARGET_PREFIX_DIR"
	ensure_dir "$TARGET_LIB_DIR"

	# Enforce flat prefix structure (/usr/local -> /).
	[[ -e "$TARGET_PREFIX_DIR/usr" ]] || ln -s . "$TARGET_PREFIX_DIR/usr"
	[[ -e "$TARGET_PREFIX_DIR/local" ]] || ln -s . "$TARGET_PREFIX_DIR/local"

	local cpu_family="${ndk_triple%%-*}"

	# Meson needs this cross file to avoid host auto-detection.
	cat >"$TARGET_PREFIX_DIR/crossfile.txt" <<CROSSFILE
[built-in options]
buildtype = 'release'
default_library = 'static'
wrap_mode = 'nodownload'
b_ndebug = 'true'
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
nm = '$NM'
ranlib = '$RANLIB'
strip = 'llvm-strip -s'
pkg-config = 'pkg-config'
[host_machine]
system = 'android'
cpu_family = '$cpu_family'
cpu = '${CC%%-*}'
endian = 'little'
CROSSFILE
}

build_target() {
	local target="$1"
	local target_dir="$DEPS_DIR/$target"
	local script_path="$BUILDSCRIPTS_DIR/scripts/$target.sh"

	if [[ -n "${ACTIVE_TARGETS[$target]:-}" ]]; then
		die "Dependency cycle detected on target: $target"
	fi
	[[ -f "$script_path" ]] || die "Build script missing: $script_path"

	ACTIVE_TARGETS[$target]=1

	local deps_var="dep_${target//-/_}[@]"
	local deps=()
	local deps_line="${!deps_var-}"
	if [[ -n "$deps_line" ]]; then
		read -r -a deps <<<"$deps_line"
	fi

	log_info "Preparing $target..."
	if [[ "${#deps[@]}" -eq 0 ]]; then
		echo >&2 "Dependencies: <none>"
	else
		echo >&2 "Dependencies: ${deps[*]}"
	fi
	for dep in "${deps[@]}"; do
		build_target "$dep"
	done

	log_info "Building $target..."
	if [[ -d "$target_dir" ]]; then
		run_in_dir "$target_dir" "$script_path"
	else
		log_info "Using virtual target: $(basename "${script_path%.sh}")"
		"$script_path"
	fi

	unset "ACTIVE_TARGETS[$target]"
}

build_native_components() {
	for arch in ${archs[@]}; do
		load_arch $arch
		setup_prefix
		build_target "${BUILD_TARGET:-libmedia_kit_native_event_loop}"
		log_info "Build $arch done."
		"$BUILDSCRIPTS_DIR/pack.sh"
	done
}

main() {
	prepare_workspace
	prepare_dependencies
	build_native_components
}

main "$@"
