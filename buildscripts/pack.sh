#!/usr/bin/env bash
set -euo pipefail

export BUILDSCRIPTS_DIR="${BUILDSCRIPTS_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")")}"
source "$BUILDSCRIPTS_DIR/include/path.sh"
source "$BUILDSCRIPTS_DIR/include/common.sh"

readonly TARGET_ABI="${TARGET_ABI:-arm64-v8a}"
readonly TARGET_LIB_DIR="${TARGET_LIB_DIR:-$BUILD_DIR/output/lib/$TARGET_ABI}"
readonly OUTPUT_JAR="$BUILD_DIR/output/default-$TARGET_ABI.jar"

stage_shared_objects() {
	local so_file_count

	require_file \
		"$TARGET_LIB_DIR/libmedia_kit_native_event_loop.so"

	so_file_count="$(find "$TARGET_LIB_DIR" -maxdepth 1 -type f -name "*.so*" | wc -l)"
	if [[ "$so_file_count" -eq 0 ]]; then
		die "No shared objects found in $TARGET_LIB_DIR; refusing to create empty jar."
	fi
}

package_output_jar() {
	require_dir "$TARGET_LIB_DIR"
	ensure_dir "$BUILD_DIR/output"
	rm -f "$OUTPUT_JAR"
	run_in_dir "$BUILD_DIR/output" zip -q -r "$(basename "$OUTPUT_JAR")" "lib/$TARGET_ABI"
}

main() {
	stage_shared_objects
	package_output_jar
}

main "$@"
