#!/bin/bash

# /scripts/build.sh
# 
# Builds docker image
#
# For local use only

ENV=${1:-"dev"}
IMAGE_TAG=${2:-"test"}

IMAGE_NAME="lift-model-local"

echo "Building docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build --no-cache --provenance=false --platform linux/amd64 -t ${IMAGE_NAME}:${IMAGE_TAG} .
