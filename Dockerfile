FROM debian:jessie
MAINTAINER Zachary Carter "carterza@gmail.com"

RUN REPO=http://cdn-fastly.deb.debian.org && \
  echo "deb $REPO/debian jessie main\ndeb $REPO/debian jessie-updates main\ndeb $REPO/debian-security jessie/updates main" > /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update --yes && apt-get install --yes \
  automake \
  autogen \
  bash \
  build-essential \
  git \
  libglu1-mesa-dev freeglut3-dev mesa-common-dev \
  libopenal1 libopenal-dev \
  mercurial && \
apt-get clean --yes

RUN git clone https://github.com/nim-lang/Nim.git && cd Nim && \
    git clone --depth 1 https://github.com/nim-lang/csources.git && \
    cd csources && sh build.sh && cd ../ && bin/nim c koch && ./koch boot -d:release

RUN cd Nim && ./koch nimble

ENV PATH=${PATH}:/Nim/bin

RUN git clone https://github.com/fragworks/frag.git && cd frag && git submodule update --init vendor/bx vendor/bgfx/ vendor/bimg