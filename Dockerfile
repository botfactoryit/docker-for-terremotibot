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

# Install GraphicsMagick
RUN cd /tmp && wget http://ftp.icm.edu.pl/pub/unix/graphics/GraphicsMagick/1.3/GraphicsMagick-1.3.25.tar.gz \
    && tar zxvf GraphicsMagick-1.3.25.tar.gz && cd GraphicsMagick-1.3.25 \
    && ./configure && make && make install && rm -rf GraphicsMagick-* 

# Install ffmpeg
RUN cd /tmp && wget https://github.com/nareix/ffmpeg-static-builds/releases/download/3.1.3/ffmpeg-release-64bit-static.tar.xz \
    && tar xf ffmpeg-release-64bit-static.tar.xz \
    && cd ffmpeg-3.1.3-64bit-static && mv ffmpeg /usr/bin

# Install vapoursynth build deps
RUN pip3 install cython \
    && wget -qO- https://github.com/sekrit-twc/zimg/archive/release-2.9.2.tar.gz | tar -zxf- \
    && cd zimg-release-2.9.2 \
    && ./autogen.sh && ./configure && make install

# Install vapoursynth
RUN git clone https://github.com/vapoursynth/vapoursynth.git \
    && cd vapoursynth && ./autogen.sh && ./configure \
    && make install && ldconfig /usr/local/lib \
    && PYTHON3_LOCAL_LIB_PATH=$(echo /usr/local/lib/python3.*) \
    && ln -s $PYTHON3_LOCAL_LIB_PATH/site-packages/vapoursynth.so $PYTHON3_LOCAL_LIB_PATH/dist-packages/vapoursynth.so \
    && python3 -c "from vapoursynth import core;print(core.version())"

# Install vsimagereader
RUN apt-get install -y libpng-dev libturbojpeg libjpeg-turbo8-dev && cd /tmp && wget https://github.com/botfactoryit/vsimagereader/archive/master.zip \
    && ln -s /usr/lib/x86_64-linux-gnu/libturbojpeg.so.0 /usr/lib/x86_64-linux-gnu/libturbojpeg.so \
    && unzip master.zip && cd vsimagereader-master/src && chmod +x configure && ./configure && make && mv imagereader.o /usr/bin \
    && mkdir -p /root/.config/vapoursynth/ && echo "UserPluginDir=/usr/bin" > $HOME/.config/vapoursynth/vapoursynth.conf \
    && cat $HOME/.config/vapoursynth/vapoursynth.conf
