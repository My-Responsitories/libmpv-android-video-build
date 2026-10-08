#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"
source "$BUILDSCRIPTS_DIR/include/depinfo.sh"

ensure_meson() {
	log_info "Installing nasm meson..."
	sudo apt-get update
	sudo apt-get install -y nasm
	python3 -m pip install meson
}

clone_repo() {
	local dest="$1"
	local branch="$2"
	local url="$3"
	shift 3

	git clone --depth 1 --single-branch --no-tags -b "$branch" "$@" "$url" "$dest"
}

clean_repo() {
	local repo_dir="$1"

	log_info "Cleaning existing source: $repo_dir"
	pushd "$repo_dir" >/dev/null
	git reset --hard
	git clean -fdx
	git submodule foreach --recursive git reset --hard
	git submodule foreach --recursive git clean -fdx
	popd >/dev/null
}

queue_clone() {
	local dest="$1"

	if [[ -d "$dest/.git" ]]; then
		clean_repo "$dest" &
		return
	fi
	if [[ -e "$dest" ]]; then
		log_info "Removing non-git source tree: $dest"
		rm -rf "$dest"
	fi

	clone_repo "$@" &
}

queue_default_repos() {
	queue_clone "mpv" "v$v_mpv" "https://github.com/mpv-player/mpv.git"
	queue_clone "ffmpeg" "n$v_ffmpeg" "https://github.com/FFmpeg/FFmpeg.git"
	queue_clone "mbedtls" "v$v_mbedtls" "https://github.com/Mbed-TLS/mbedtls.git" --recurse-submodules --shallow-submodules
	queue_clone "libwebp" "v$v_libwebp" "https://github.com/webmproject/libwebp.git"
	queue_clone "libass" "$v_libass" "https://github.com/libass/libass.git"
	queue_clone "freetype" "VER-$v_freetype" "https://gitlab.freedesktop.org/freetype/freetype.git"
	queue_clone "fribidi" "v$v_fribidi" "https://github.com/fribidi/fribidi.git"
	queue_clone "harfbuzz" "$v_harfbuzz" "https://github.com/harfbuzz/harfbuzz.git"
	queue_clone "libplacebo" "v$v_libplacebo" "https://code.videolan.org/videolan/libplacebo.git" --recurse-submodules --shallow-submodules
	queue_clone "media_kit" "native" "https://github.com/My-Responsitories/media-kit.git"
}

queue_optional_repos() {
	if is_enabled "ENABLE_DAV1D"; then
		queue_clone "dav1d" "$v_dav1d" "https://code.videolan.org/videolan/dav1d.git"
	fi

	if is_enabled "ENABLE_VULKAN"; then
		# shaderc is provided by the NDK source tree and does not need cloning.
		ensure_dir "$DEPS_DIR/shaderc"
	fi
}

download_all_repos() {
	queue_default_repos
	queue_optional_repos
	wait
}

ensure_meson
ensure_dir "$DEPS_DIR"

run_in_dir "$DEPS_DIR" download_all_repos
