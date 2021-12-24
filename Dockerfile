FROM node:16.13.1
ARG DEBIAN_FRONTEND=noninteractive

# Merry Christmas!
ENV REFRESHED_AT 2021-12-24

# Install GM
RUN apt-get update && apt-get install -y graphicsmagick
