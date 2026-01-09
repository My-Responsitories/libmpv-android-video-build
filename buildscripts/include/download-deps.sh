#!/bin/bash -e

. ./include/depinfo.sh

[ -z "$WGET" ] && WGET=wget

set -euo pipefail

mkdir -p deps && cd deps

git config --global advice.detachedHead false

# mbedtls
[ ! -d mbedtls ] && git clone --depth 1 --branch v$v_mbedtls --recurse-submodules --shallow-submodules https://github.com/Mbed-TLS/mbedtls.git mbedtls

# dav1d
[ ! -d dav1d ] && git clone --depth 1 --branch $v_dav1d https://code.videolan.org/videolan/dav1d.git dav1d

# libvpx
[ ! -d libvpx ] && git clone --depth 1 --branch meson-$v_libvpx https://gitlab.freedesktop.org/gstreamer/meson-ports/libvpx.git

# libx264
[ ! -d libx264 ] && git clone --depth 1 https://code.videolan.org/videolan/x264.git --branch master libx264

# ffmpeg
[ ! -d ffmpeg ] && git clone --depth 1 --branch n$v_ffmpeg https://github.com/FFmpeg/FFmpeg.git ffmpeg

# freetype2
[ ! -d freetype ] && git clone --depth 1 --branch VER-$v_freetype https://gitlab.freedesktop.org/freetype/freetype.git freetype

# fribidi
[ ! -d fribidi ] && git clone --depth 1 --branch v$v_fribidi https://github.com/fribidi/fribidi.git fribidi

# harfbuzz
[ ! -d harfbuzz ] && git clone --depth 1 --branch $v_harfbuzz https://github.com/harfbuzz/harfbuzz.git harfbuzz

# libass
[ ! -d libass ] && git clone --depth 1 --branch $v_libass https://github.com/libass/libass.git libass

# libwebp
[ ! -d libwebp ] && git clone --depth 1 --branch v$v_libwebp https://github.com/webmproject/libwebp libwebp

# shaderc
mkdir -p shaderc
cat >shaderc/README <<'HEREDOC'
Shaderc sources are provided by the NDK.
see <ndk>/sources/third_party/shaderc
HEREDOC

# libplacebo
[ ! -d libplacebo ] && git clone --depth 1 --branch v$v_libplacebo --recurse-submodules --shallow-submodules https://code.videolan.org/videolan/libplacebo.git libplacebo

# mpv
[ ! -d mpv ]  && git clone --depth 1 --branch v$v_mpv https://github.com/mpv-player/mpv.git mpv

# fftools_ffi
[ ! -d fftools_ffi ] && git clone --depth 1 --branch main https://github.com/moffatman/fftools-ffi.git fftools_ffi

# media-kit-android-helper
[ ! -d media-kit-android-helper ] && git clone --depth 1 --branch main https://github.com/media-kit/media-kit-android-helper.git media-kit-android-helper

# media_kit
[ ! -d media_kit ] && git clone --depth 1 --single-branch --branch version_1.2.5 https://github.com/bggRGjQaUbCoE/media-kit.git media_kit

cd ..