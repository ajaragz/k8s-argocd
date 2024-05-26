#!/bin/bash

set -euo pipefail

DOCKER_USER="${DOCKER_USER:-ajarag}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

fail() {
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

[[ $# -ne 1 ]] && fail "missing component directory"

image_name=$(basename "${1}")

set -x

docker build -t "${DOCKER_USER}/${image_name}:${IMAGE_TAG}" -f Dockerfile "${image_name}"
docker push "${DOCKER_USER}/${image_name}:${IMAGE_TAG}"

if [[ "${IMAGE_TAG}" != "latest" ]]; then
    docker image tag "${DOCKER_USER}/${image_name}:${IMAGE_TAG}" "${DOCKER_USER}/${image_name}:latest"
    docker push "${DOCKER_USER}/${image_name}:latest"
fi
