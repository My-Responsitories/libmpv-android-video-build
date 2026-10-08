#!/usr/bin/env bash
set -euo pipefail

export GRADLE_OPTS="-Dorg.gradle.daemon=false"
export JAVA_HOME="${JAVA_HOME_17_X64:-${JAVA_HOME:-}}"
export CUSTOM_FFMPEG_OPTIONS=

# export ENABLE_VULKAN=1
# export ENABLE_DAV1D=1

# export NDK_WRAPPER_DISABLED=1

buildscripts/build.sh
