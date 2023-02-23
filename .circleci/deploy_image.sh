#!/bin/bash
#-------------------------------------------------------------------------------
set -e

cd "$(dirname $(dirname "${BASH_SOURCE[0]}"))"

case $(uname -m) in
    x86_64 | amd64) ARCHITECTURE="amd64" ;;
    aarch64 | arm64) ARCHITECTURE="arm64" ;;
    *) echo "Unsupported CPU architecture: $(uname -m)"; exit 1 ;;
esac

VERSION="${1}"
PKG_DOCKER_IMAGE="zimagi/action-command"
#-------------------------------------------------------------------------------

if [ -z "$VERSION" ]; then
    VERSION="$(cat VERSION)"
fi

if [ -z "$PKG_DOCKER_USER" ]; then
    echo "PKG_DOCKER_USER environment variable must be defined to deploy image"
    exit 1
fi
if [ -z "$PKG_DOCKER_PASSWORD" ]; then
    echo "PKG_DOCKER_PASSWORD environment variable must be defined to deploy image"
    exit 1
fi

echo "Logging into DockerHub"
echo "$PKG_DOCKER_PASSWORD" | docker login --username "$PKG_DOCKER_USER" --password-stdin

TAG="${VERSION}-${ARCHITECTURE}"

echo "Building Docker image: ${TAG}"
docker build --force-rm --no-cache \
    --file "Dockerfile" \
    --tag "${PKG_DOCKER_IMAGE}:${TAG}" \
    --platform "linux/${ARCHITECTURE}" \
    .

echo "Pushing ${ARCHITECTURE} Docker image: ${TAG}"
docker push "${PKG_DOCKER_IMAGE}:${TAG}"
