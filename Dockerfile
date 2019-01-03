# It's tricky to build on Alpine because of absense of pre-built libomxil-bellagio
FROM debian:stretch-slim

ENV FFMPEG_VERSION=4.1

ARG FFMPEG_CONFIGURE_OPTIONS="\
 --disable-everything \
 --enable-ffmpeg \
 --enable-decoder=rawvideo \
 --enable-muxer=hls \
 --enable-omx-rpi \
"

WORKDIR /tmp/

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential pkg-config libomxil-bellagio-dev wget yasm && \
    wget -O - https://www.ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.xz | tar xvJf - && \
    cd ffmpeg-${FFMPEG_VERSION} && \
    ./configure ${FFMPEG_CONFIGURE_OPTIONS} && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -r ffmpeg-${FFMPEG_VERSION} && \
    apt-get remove -y --purge build-essential pkg-config libomxil-bellagio-dev wget yasm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

CMD ["ffmpeg"]