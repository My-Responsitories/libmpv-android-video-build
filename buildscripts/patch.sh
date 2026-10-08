#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"

apply_dep_patches() {
	local dep_path="$1"
	local dep_name
	dep_name="$(basename "$dep_path")"
	local deps_root="${DEPS_DIR:-deps}"
	local dep_dir="$deps_root/$dep_name"

	if [[ ! -d "$dep_dir" ]]; then
		log_info "Skipping patches for missing dependency: $dep_name"
		return
	fi

	mapfile -t dep_patches < <(find "$dep_path" -maxdepth 1 -type f | sort)
	if [[ "${#dep_patches[@]}" -eq 0 ]]; then
		return
	fi

	pushd "$dep_dir" >/dev/null
	log_info "Patching $dep_name"
	git reset --hard
	git clean -fdx
	for patch in "${dep_patches[@]}"; do
		log_info "Applying $patch"
		git apply "$patch"
	done
	popd >/dev/null
}

main() {
	local dep_path
	for dep_path in "$BUILDSCRIPTS_DIR"/patches/*; do
		[[ -d "$dep_path" ]] || continue
		apply_dep_patches "$dep_path"
	done
}

main "$@"
