#!/usr/bin/env bash
set -euo pipefail

readonly -a NDK_ALIAS_DIRS=(
	"26.1.10909125"
	"27.0.12077973"
	"28.2.13676358"
)

refresh_ndk_aliases() {
	local ndk_parent_dir
	ndk_parent_dir="$(dirname "$ANDROID_NDK_LATEST_HOME")"
	local current_ndk
	current_ndk="$(basename "$ANDROID_NDK_LATEST_HOME")"

	pushd "$ndk_parent_dir" >/dev/null
	for alias in "${NDK_ALIAS_DIRS[@]}"; do
		if [[ -e "$alias" || -L "$alias" ]]; then
			sudo rm -rf "$alias"
		fi
		ln -sfn "$current_ndk" "$alias"
	done
	popd >/dev/null
}

install_wrapper() {
	local wrapper_src="$BUILDSCRIPTS_DIR/ndk-wrapper.py"
	local bin_dir="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"
	local wrapper_dst="$bin_dir/ndk-wrapper.py"
	local tool tool_path backup_path

	install -m 0755 "$wrapper_src" "$wrapper_dst"
	printf 'Installed wrapper: %s\n' "$wrapper_dst"

	for tool in clang clang++; do
		tool_path="$bin_dir/$tool"
		backup_path="${tool_path}_"

		if [[ ! -e "$backup_path" ]]; then
			if [[ "$tool" == "clang++" && -L "$tool_path" ]]; then
				# Keep clang++_ pointing at clang_ to avoid wrapper recursion.
				rm -f "$tool_path"
				ln -sfn "clang_" "$backup_path"
			else
				mv "$tool_path" "$backup_path"
			fi
		fi

		ln -sfn "ndk-wrapper.py" "$tool_path"
	done
}

main() {
	refresh_ndk_aliases
	install_wrapper
}

main "$@"
