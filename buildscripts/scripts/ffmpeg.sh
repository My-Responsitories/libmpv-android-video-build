#!/bin/bash -e
mkdir -p $build_dir
pushd $build_dir

cpu=armv7-a
[[ "$ndk_triple" == "aarch64"* ]] && cpu=armv8-a
[[ "$ndk_triple" == "x86_64"* ]] && cpu=generic

cpuflags=
[[ "$ndk_triple" == "arm"* ]] && cpuflags="$cpuflags -mfpu=neon -mcpu=cortex-a8"

../configure \
	--target-os=android \
	--enable-cross-compile \
	--cross-prefix=$ndk_triple- \
	--cc=$CC \
	--ar=$AR \
	--nm=$NM \
	--ranlib=$RANLIB \
	--arch=${ndk_triple%%-*} \
	--cpu=$cpu \
	--pkg-config=pkg-config \
	--extra-cflags="-I$prefix_dir/include $cpuflags" \
	--extra-ldflags="-L$prefix_dir/lib" \
	\
	--disable-gpl \
	--disable-nonfree \
	--enable-version3 \
	--enable-static \
	--disable-shared \
	--disable-vulkan \
	--disable-iconv \
	--disable-debug \
	--pkg-config-flags=--static \
	\
	--disable-muxers \
	--disable-decoders \
	--disable-encoders \
	--disable-demuxers \
	--disable-parsers \
	--disable-protocols \
	--disable-devices \
	--disable-filters \
	--disable-doc \
	--disable-avdevice \
	--disable-programs \
	--disable-gray \
	--disable-swscale-alpha \
	\
	--enable-jni \
	--enable-bsfs \
	--enable-mediacodec \
	\
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vdpau \
	--disable-bzlib \
	--disable-linux-perf \
	--disable-videotoolbox \
	--disable-audiotoolbox \
	\
	--enable-small \
	--enable-hwaccels \
	--enable-optimizations \
	--enable-runtime-cpudetect \
	\
	--enable-mbedtls \
	\
	--enable-libdav1d \
	\
	--enable-avutil \
	--enable-avcodec \
	--enable-avfilter \
	--enable-avformat \
	--enable-swscale \
	--enable-swresample \
	\
	--enable-libwebp \
	\
	--enable-decoder=flv \
	--enable-decoder=h264* \
	--enable-decoder=mpeg1video \
	--enable-decoder=mpeg4* \
	--enable-decoder=vp8* \
	--enable-decoder=vp9* \
	--enable-decoder=hevc* \
	--enable-decoder=av1* \
	--enable-decoder=libdav1d \
	\
	--enable-decoder=aac* \
	--enable-decoder=ac3 \
	--enable-decoder=eac3 \
	--enable-decoder=flac \
	--enable-decoder=mp3* \
	--enable-decoder=opus \
	--enable-decoder=wavpack \
	--enable-decoder=pcm* \
	\
	--enable-decoder=srt \
	--enable-decoder=subrip \
	--enable-decoder=webvtt \
	--enable-decoder=movtext \
	\
	--enable-demuxer=concat \
	--enable-demuxer=data \
	--enable-demuxer=flv \
	--enable-demuxer=hls \
	--enable-demuxer=live_flv \
	--enable-demuxer=loas \
	--enable-demuxer=m4v \
	--enable-demuxer=mov \
	--enable-demuxer=mpegps \
	--enable-demuxer=mpegts \
	--enable-demuxer=mpegvideo \
	--enable-demuxer=hevc \
	--enable-demuxer=av1 \
	--enable-demuxer=matroska \
	--enable-demuxer=webm_dash_manifest \
	--enable-muxer=webp \
	\
	--enable-demuxer=aac \
	--enable-demuxer=ac3 \
	--enable-demuxer=au \
	--enable-demuxer=flac \
	--enable-demuxer=mp3 \
	--enable-demuxer=wav \
	\
	--enable-demuxer=srt \
	--enable-demuxer=webvtt \
	\
	--enable-parser=h264 \
	--enable-parser=hevc \
	--enable-parser=mpeg4video \
	--enable-parser=mpegvideo \
	\
	--enable-parser=aac* \
	--enable-parser=ac3 \
	--enable-parser=flac \
	--enable-parser=mpegaudio \
	\
	--enable-filter=overlay \
	--enable-filter=equalizer \
	--enable-filter=aresample \
	--enable-filter=dynaudnorm \
	--enable-filter=loudnorm \
	--enable-filter=alimiter \
	\
	--enable-protocol=async \
	--enable-protocol=cache \
	--enable-protocol=crypto \
	--enable-protocol=file \
	--enable-protocol=ftp \
	--enable-protocol=hls \
	--enable-protocol=http \
	--enable-protocol=httpproxy \
	--enable-protocol=https \
	--enable-protocol=pipe \
	--enable-protocol=subfile \
	--enable-protocol=tcp \
	--enable-protocol=tls \
	\
	--enable-encoder=png \
	--enable-encoder=libwebp \
	--enable-encoder=libwebp_anim \
	\
	--enable-network \

$_MAKE
DESTDIR="$prefix_dir" $_MAKE install

popd
