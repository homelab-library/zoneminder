#!/usr/bin/env bash
set -Eeuo pipefail

# Enable docker cross-compilation using qemu
if [ ! -f "/proc/sys/fs/binfmt_misc/qemu-aarch64" ]; then
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    # docker buildx create --platform linux/arm64,linux/amd64 --name cross-builder --append
    # docker buildx use cross-builder
fi

# Run build
docker buildx build --platform linux/arm64,linux/amd64 .
docker buildx build -t proctorlabs/zoneminder:meta --load .
ZMVERSION=$(docker run --rm -it --entrypoint '' proctorlabs/zoneminder:meta /usr/bin/zmc --version | tr -d '[:space:]')
docker buildx build --platform linux/arm64,linux/amd64 \
    -t "proctorlabs/zoneminder:v${ZMVERSION}" \
    -t "proctorlabs/zoneminder:v${ZMVERSION%.*}" \
    -t "proctorlabs/zoneminder:latest" --push .
