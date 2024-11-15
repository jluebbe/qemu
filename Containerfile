#FROM debian:bookworm AS base-stage
FROM ghcr.io/rauc/rauc/rauc-ci:latest AS base-stage

FROM base-stage AS build-stage

USER root

RUN apt-get update && \
  apt-get install -q -y --no-install-recommends \
  bzip2 \
  gcc \
  g++ \
  meson \
  make \
  python3-venv \
  libtool \
  libslirp-dev

COPY ./ /src/

RUN cd /src && \
  mkdir build && cd build && \
  ../configure \
    --target-list=x86_64-softmmu \
    --disable-curl \
    --disable-docs \
    --disable-fdt \
    --disable-hv-balloon \
    --disable-libudev \
    --disable-libvduse \
    --disable-tpm \
    --disable-vhost-user \
    --disable-replication \
    --disable-selinux \
    --disable-l2tpv3 \
    --disable-oss \
    --disable-dbus-display \
    --disable-tools \
    --disable-keyring \
    --enable-slirp \
    --enable-strip \
    --prefix=/usr/local && \
  make -j 8 && \
  make install

FROM base-stage AS final-stage

RUN sudo apt-get update && \
  sudo apt-get install -q -y --no-install-recommends \
  mmc-utils

COPY --from=build-stage /usr/local /usr/local
