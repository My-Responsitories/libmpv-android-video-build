#!/bin/bash
export ROOT_DIR=$(realpath $BUILDSCRIPTS_DIR/..)
export BUILD_DIR=$ROOT_DIR/build
export DEPS_DIR=$BUILD_DIR/deps
export PREFIX_DIR=$BUILD_DIR/prefix

export PATH="$ANDROID_NDK_LATEST_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
unset ANDROID_SDK_ROOT ANDROID_NDK_ROOT
