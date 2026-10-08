#!/bin/bash -e
: "${TARGET_PREFIX_DIR:?TARGET_PREFIX_DIR is not set}"

application_mk=$PWD/../../../app/src/main/jni/Application.mk # APP_{PLATFORM,STL} are imported from here

abi=arm64-v8a

# build using the NDK's scripts, but keep object files in our build dir
pushd $ANDROID_NDK_LATEST_HOME/sources/third_party/shaderc

ndk-build -j$(nproc) \
	NDK_PROJECT_PATH=. \
	APP_BUILD_SCRIPT=Android.mk \
	APP_PLATFORM=android-24 \
	APP_STL=c++_shared \
	APP_ABI=$abi \
	NDK_APP_OUT="$build_dir" \
	NDK_APP_LIBS_OUT="$build_dir/libs" \
	libshaderc_combined

pushd $build_dir
cp -vr include/* "$TARGET_PREFIX_DIR/include"
cp -v libs/*/$abi/libshaderc.a "$TARGET_PREFIX_DIR/lib/libshaderc_combined.a"
popd

popd

# create a pkgconfig file
# The /usr/local references may look redundant but are needed to force pkg-config
# to emit the sysroot include or lib path at least one (or it wouldn't work).
mkdir -p "$TARGET_PREFIX_DIR"/lib/pkgconfig
cat >"$TARGET_PREFIX_DIR"/lib/pkgconfig/shaderc_combined.pc <<"END"
Name: shaderc_combined
Description:
Version: 2022.3-unknown
Libs: -L/usr/local/lib -lshaderc_combined
Cflags: -I/usr/local/include
END

# Android provides Vulkan, but no pkgconfig file
# you can double-check the version in vulkan_core.h (-> VK_HEADER_VERSION)
mkdir -p "$TARGET_PREFIX_DIR"/lib/pkgconfig
cat >"$TARGET_PREFIX_DIR"/lib/pkgconfig/vulkan.pc <<"END"
Name: Vulkan
Description:
Version: 1.3.275
Libs: -lvulkan
Cflags:
END
