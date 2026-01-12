#!/bin/bash
export GRADLE_OPTS=-Dorg.gradle.daemon=false
export JAVA_HOME=$JAVA_HOME_21_X64
export NDK_WRAPPER_APPEND="-mcpu=cortex-x3+crypto+sha3+nosve -mtune=cortex-a510"

buildscripts/bundle_default.sh
