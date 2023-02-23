#!/bin/bash
#-------------------------------------------------------------------------------
set -e

cd "$(dirname $(dirname "${BASH_SOURCE[0]}"))"

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

echo "Creating Docker manifest: ${VERSION}"
TAG="$VERSION"

docker manifest create "${PKG_DOCKER_IMAGE}:${TAG}" \
    --amend "${PKG_DOCKER_IMAGE}:${TAG}-amd64" \
    --amend "${PKG_DOCKER_IMAGE}:${TAG}-arm64"

echo "Pushing Docker manifest: ${TAG}"
docker manifest push "${PKG_DOCKER_IMAGE}:${TAG}"
