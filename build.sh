#!/bin/bash
export GRADLE_OPTS=-Dorg.gradle.daemon=false
export JAVA_HOME=$JAVA_HOME_21_X64
export CUSTOM_FFMPEG_OPTIONS=
export ENABLE_VULKAN=
export ENABLE_DAV1D=

# export ENABLE_VULKAN=1
export ENABLE_DAV1D=1

buildscripts/bundle_default.sh
