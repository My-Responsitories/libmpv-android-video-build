#!/usr/bin/env bash
# Dependency versions
v_mpv=0.41.0
v_ffmpeg=9.0.2
v_mbedtls=3.6.5
v_dav1d=1.5.4
v_libwebp=1.6.0
v_libass=0.17.5
v_freetype=2-14-3
v_fribidi=1.0.16
v_harfbuzz=14.3.1
v_libplacebo=7.360.1

# Dependency tree (dep_<name> => direct dependencies)
dep_mpv=(ffmpeg libass libplacebo)
dep_ffmpeg=(mbedtls libwebp)
dep_mbedtls=()
dep_libass=(freetype fribidi harfbuzz)
dep_freetype=()
dep_fribidi=()
dep_harfbuzz=()
dep_libmedia_kit_native_event_loop=(mpv)
dep_libwebp=()
dep_libplacebo=()

if [[ -n "${ENABLE_DAV1D:-}" ]]; then
	dep_ffmpeg=(dav1d "${dep_ffmpeg[@]}")
	dep_dav1d=()
fi

if [[ -n "${ENABLE_VULKAN:-}" ]]; then
	dep_libplacebo=(shaderc)
	dep_shaderc=()
fi
