#!/bin/bash -e
## Dependency versions

v_platform=android-36
v_sdk=14742923_latest
v_ndk=29.0.14206865
v_sdk_build_tools=37.0.0
v_cmake=4.1.2

v_libass=0.17.5
v_harfbuzz=14.3.1
v_fribidi=1.0.16
v_freetype=2-14-3
v_mbedtls=3.6.5
v_libplacebo=7.360.1
v_dav1d=1.5.4
v_ffmpeg=9.0.1
v_mpv=0.41.0
v_libwebp=1.6.0


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mpv=(ffmpeg libass libplacebo)
if [ -n "$ENABLE_DAV1D" ]; then
	dep_ffmpeg=(dav1d mbedtls libwebp)
		dep_dav1d=()
else
	dep_ffmpeg=(mbedtls libwebp)
fi
		dep_mbedtls=()
		dep_libwebp=()
	dep_libass=(freetype fribidi harfbuzz)
		dep_freetype=()
		dep_fribidi=()
		dep_harfbuzz=()
if [ -n "$ENABLE_VULKAN" ]; then
	dep_libplacebo=(shaderc)
		dep_shaderc=()
else
	dep_libplacebo=()
fi
