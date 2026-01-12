#!/bin/bash -e
## Dependency versions

v_mpv=0.41.0
v_ffmpeg=8.0.1
v_mbedtls=3.6.5
v_dav1d=1.5.3
v_libwebp=1.6.0
v_libass=0.17.4
v_freetype=2-14-1
v_fribidi=1.0.16
v_harfbuzz=12.3.0
v_libplacebo=7.351.0


## Dependency tree
# I would've used a dict but putting arrays in a dict is not a thing

dep_mpv=(ffmpeg libass libplacebo)
	dep_ffmpeg=(mbedtls dav1d libwebp)
		dep_mbedtls=()
		dep_dav1d=()
		dep_libwebp=()
	dep_libass=(freetype fribidi harfbuzz)
		dep_freetype=()
		dep_fribidi=()
		dep_harfbuzz=()
	dep_libplacebo=()
