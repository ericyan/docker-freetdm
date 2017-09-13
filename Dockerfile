FROM debian:jessie-slim
LABEL maintainer "Eric Yan <docker@ericyan.me>"

ARG FS_MAJOR=1.6
RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-key D76EDC7725E010CF \
    && echo "deb http://files.freeswitch.org/repo/deb/freeswitch-$FS_MAJOR/ jessie main" \
        > /etc/apt/sources.list.d/freeswitch.list \
    && echo "deb-src http://files.freeswitch.org/repo/deb/freeswitch-$FS_MAJOR/ jessie main" \
        >> /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        autoconf \
        automake \
        libtool-bin \
      && mkdir -p /usr/share/man/man1/ \
      && apt-get build-dep -y freeswitch \
    && apt-get source --download-only freeswitch \
      && dpkg-source -x freeswitch_*.dsc /usr/src/freeswitch-$FS_MAJOR \
      && rm freeswitch_*.tar.xz freeswitch_*.dsc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/freeswitch-$FS_MAJOR/
RUN set -e \
    && ./bootstrap.sh \
    && echo "../../libs/freetdm/mod_freetdm" > modules.conf \
    && ./configure \
    && make all \
    && make install
