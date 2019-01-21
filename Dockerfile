# It's tricky to build on Alpine because of absense of pre-built libomxil-bellagio
FROM debian:stretch-slim

ENV FFMPEG_VERSION=4.1

# Path to OpenMAX hardware encoding libraries. They are part of Raspberry Pi firmware.
ENV LD_LIBRARY_PATH=/opt/vc/lib 

ARG FFMPEG_CONFIGURE_OPTIONS="\
 --disable-debug \
 --disable-doc \
 --disable-programs \
 --disable-everything \
 --enable-ffmpeg \
 --enable-decoder=rawvideo \
 --enable-decoder=pcm_s16le \
 --enable-encoder=h264_omx --enable-omx-rpi\
 --enable-encoder=aac \
 --enable-muxer=hls --enable-muxer=mp4 \
 --enable-protocol=file \
 --enable-indev=v4l2 \
 --enable-indev=alsa \
 --enable-filter=aresample \
"

WORKDIR /tmp/

RUN apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install -y build-essential pkg-config libomxil-bellagio-dev libasound2-dev libasound2 wget yasm && \
    wget -O - https://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz | tar xvJf - && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    ./configure ${FFMPEG_CONFIGURE_OPTIONS} && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -r ffmpeg-${FFMPEG_VERSION} && \
    apt-get remove -y --purge build-essential pkg-config libomxil-bellagio-dev libasound2-dev wget yasm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

CMD ["ffmpeg"]

