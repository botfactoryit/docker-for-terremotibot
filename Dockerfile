FROM ubuntu:18.04
LABEL mantainer Francesco Tonini <francescoantoniotonini@gmail.com>
ENV REFRESHED_AT 2019-08-26

# Add Build stuff
RUN apt-get update \
    && apt-get install -y software-properties-common build-essential autoconf automake \
    libtool pkg-config python3-pip curl git wget unzip

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

# Add yarn (--no-install-recommends avoids nodejs installation)
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y --no-install-recommends yarn=1.6.0-1

# Compile GraphicsMagick
RUN cd /tmp && wget http://ftp.icm.edu.pl/pub/unix/graphics/GraphicsMagick/1.3/GraphicsMagick-1.3.25.tar.gz \
    && tar zxvf GraphicsMagick-1.3.25.tar.gz && cd GraphicsMagick-1.3.25 \
    && ./configure && make && make install && rm -rf GraphicsMagick-*

# Install ffmpeg
RUN cd /tmp && wget https://github.com/nareix/ffmpeg-static-builds/releases/download/3.1.3/ffmpeg-release-64bit-static.tar.xz \
    && tar xf ffmpeg-release-64bit-static.tar.xz \
    && cd ffmpeg-3.1.3-64bit-static && mv ffmpeg /usr/bin

# Install and compile vapoursynth build deps
RUN cd /tmp && apt-get install -y libpng-dev && pip3 install cython \
    && wget -qO- https://github.com/sekrit-twc/zimg/archive/release-2.9.2.tar.gz | tar -zxf- \
    && cd zimg-release-2.9.2 \
    && ./autogen.sh && ./configure && make install \
    && cd /tmp && wget https://www.imagemagick.org/download/ImageMagick.tar.gz \
    && tar xvzf ImageMagick.tar.gz && cd ImageMagick-7.0.8-62/ && ./configure \
    && make && make install && ldconfig /usr/local/lib

# Compile vapoursynth
RUN cd /tmp && git clone https://github.com/vapoursynth/vapoursynth.git \
    && cd vapoursynth && ./autogen.sh && ./configure --enable-imwri \
    && make install && ldconfig /usr/local/lib \
    && PYTHON3_LOCAL_LIB_PATH=$(echo /usr/local/lib/python3.*) \
    && ln -s $PYTHON3_LOCAL_LIB_PATH/site-packages/vapoursynth.so $PYTHON3_LOCAL_LIB_PATH/dist-packages/vapoursynth.so \
    && python3 -c "from vapoursynth import core;print(core.version())"

# Cleanup
RUN rm -rf /tmp/* && apt-get -y remove build-essential git autoconf automake wget pkg-config \
    libtool libpng-dev unzip software-properties-common curl
