FROM ubuntu:18.04
LABEL mantainer Francesco Tonini <francescoantoniotonini@gmail.com>
ENV REFRESHED_AT 2019-08-26

# Add build stuff
RUN apt-get update && apt-get install -y autoconf automake build-essential curl \
    libfreetype6-dev libjpeg-turbo8-dev libpng-dev libtool git pkg-config python3-pip \
    software-properties-common

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

# Compile GraphicsMagick
RUN cd /tmp && curl -sL http://ftp.icm.edu.pl/pub/unix/graphics/GraphicsMagick/1.3/GraphicsMagick-1.3.25.tar.gz | tar xz \
    && cd GraphicsMagick-1.3.25 && ./configure && make && make install

# Install ffmpeg
RUN cd /tmp && curl -sL https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.1.4-amd64-static.tar.xz | tar xJ \
    && cd ffmpeg-4.1.4-amd64-static && mv ffmpeg /usr/bin

# Install and compile vapoursynth build deps
RUN cd /tmp && pip3 install cython \
    && curl -sL https://github.com/sekrit-twc/zimg/archive/release-2.9.2.tar.gz | tar xz \
    && cd zimg-release-2.9.2 \
    && ./autogen.sh && ./configure && make install \
    && cd /tmp && curl -sL https://www.imagemagick.org/download/ImageMagick.tar.gz | tar xz \
    && cd ImageMagick-7.0.8-62/ && ./configure && make \
    && make install && ldconfig /usr/local/lib

# Compile vapoursynth
RUN cd /tmp && git clone https://github.com/vapoursynth/vapoursynth.git \
    && cd vapoursynth && ./autogen.sh && ./configure --enable-imwri \
    && make install && ldconfig /usr/local/lib \
    && PYTHON3_LOCAL_LIB_PATH=$(echo /usr/local/lib/python3.*) \
    && ln -s $PYTHON3_LOCAL_LIB_PATH/site-packages/vapoursynth.so $PYTHON3_LOCAL_LIB_PATH/dist-packages/vapoursynth.so

# Cleanup
RUN rm -rf /tmp/* && apt-get -y remove build-essential autoconf automake \
    pkg-config software-properties-common
