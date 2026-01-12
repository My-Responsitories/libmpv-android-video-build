#!/bin/bash -e
source $BUILDSCRIPTS_DIR/include/depinfo.sh

# Get dependencies for a target using indirect variable expansion
getdeps() {
	varname="dep_${1//-/_}[*]"
	echo ${!varname}
}

loadarch() {
	unset CC CXX CPATH LIBRARY_PATH C_INCLUDE_PATH CPLUS_INCLUDE_PATH

	local api_level=24
	export ndk_suffix=-arm64
	export ndk_triple=aarch64-linux-android
	local cc_triple=$ndk_triple$api_level
	export build_dir="_build$ndk_suffix"
	local prefix_name=arm64-v8a
	export prefix_dir="$PREFIX_DIR/$prefix_name"
	export native_dir="$ROOT_DIR/libmpv/src/main/jniLibs/$prefix_name"

	export CC=$cc_triple-clang
	export CXX=$cc_triple-clang++
	export AS=$CC
	export AR=llvm-ar
	export NM=llvm-nm
	export RANLIB=llvm-ranlib

	export _MESON="meson setup $build_dir --cross-file $prefix_dir/crossfile.txt"
	export _MAKE="make -j$(nproc) V=1 VERBOSE=1"
	export _NINJA="ninja -v -j$(nproc) -C $build_dir"

	export PKG_CONFIG_SYSROOT_DIR="$prefix_dir"
	export PKG_CONFIG_LIBDIR="$PKG_CONFIG_SYSROOT_DIR/lib/pkgconfig"
	unset PKG_CONFIG_PATH
}

setup_prefix() {
	if [ ! -d "$prefix_dir" ]; then
		mkdir -p "$prefix_dir"
		# enforce flat structure (/usr/local -> /)
		ln -s . "$prefix_dir/usr"
		ln -s . "$prefix_dir/local"
	fi

	if [ ! -d "$native_dir" ]; then
		mkdir -p "$native_dir"
	fi

	local cpu_family=${ndk_triple%%-*}

	# meson wants to be spoonfed this file, so create it ahead of time
	# also define: release build, static libs and no source downloads at runtime(!!!)
	cat >"$prefix_dir/crossfile.txt" <<CROSSFILE
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
strip = 'llvm-strip'
pkg-config = 'pkg-config'
[host_machine]
system = 'android'
cpu_family = '$cpu_family'
cpu = '${CC%%-*}'
endian = 'little'
CROSSFILE
}

build() {
	if [ ! -d $DEPS_DIR/$1 ]; then
		printf >&2 '\e[1;31m%s\e[m\n' "Target $1 not found"
		exit 1
	fi
	printf >&2 '\e[1;34m%s\e[m\n' "Preparing $1..."
	local deps=$(getdeps $1)
	echo >&2 "Dependencies: $deps"
	for dep in $deps; do
		build $dep
	done

	printf >&2 '\e[1;34m%s\e[m\n' "Building $1..."
	pushd $DEPS_DIR/$1
	$BUILDSCRIPTS_DIR/scripts/$1.sh
	popd
}

loadarch
setup_prefix
build mpv

exit 0
