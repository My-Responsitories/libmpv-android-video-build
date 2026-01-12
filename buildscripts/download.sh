#!/bin/bash -e
source $BUILDSCRIPTS_DIR/include/depinfo.sh

set -euo pipefail

# Dependencies
pip install meson

GIT_CLONE="git clone --depth 1 --single-branch --no-tags"

mkdir -p $DEPS_DIR
pushd $DEPS_DIR

# flutter
git clone --depth 1 --single-branch -b stable https://github.com/flutter/flutter &

# mbedtls
$GIT_CLONE -b v$v_mbedtls --recurse-submodules --shallow-submodules https://github.com/Mbed-TLS/mbedtls.git mbedtls &

# dav1d
$GIT_CLONE -b $v_dav1d https://code.videolan.org/videolan/dav1d.git dav1d &

# ffmpeg
$GIT_CLONE -b n$v_ffmpeg https://github.com/FFmpeg/FFmpeg.git ffmpeg &

# freetype2
$GIT_CLONE -b VER-$v_freetype https://gitlab.freedesktop.org/freetype/freetype.git freetype &

# fribidi
$GIT_CLONE -b v$v_fribidi https://github.com/fribidi/fribidi.git fribidi &

# harfbuzz
$GIT_CLONE -b $v_harfbuzz https://github.com/harfbuzz/harfbuzz.git harfbuzz &

# libass
$GIT_CLONE -b $v_libass https://github.com/libass/libass.git libass &

# libwebp
$GIT_CLONE -b v$v_libwebp https://github.com/webmproject/libwebp.git libwebp &

# libplacebo
$GIT_CLONE -b v$v_libplacebo --recurse-submodules --shallow-submodules https://code.videolan.org/videolan/libplacebo.git libplacebo &

# mpv
$GIT_CLONE -b v$v_mpv https://github.com/mpv-player/mpv.git mpv &

# media-kit-android-helper
$GIT_CLONE -b main https://github.com/media-kit/media-kit-android-helper.git media-kit-android-helper &

# media_kit
$GIT_CLONE -b version_1.2.5 https://github.com/bggRGjQaUbCoE/media-kit.git media_kit &

wait

popd
