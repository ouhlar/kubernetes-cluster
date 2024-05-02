#!/bin/bash

# This script is designed to automate the process of building a Docker image
# for a student container and then uploading it to the Docker Hub registry.
# It tags the image with either a user-specified tag (passed as the first argument)
# or defaults to 'latest' if no tag is provided.
# 
# Usage:
#   ./container_upload.sh [tag]
# 
# Parameters:
#   tag (optional): The tag to assign to the Docker image. Defaults to 'latest'.
# 
# Prerequisites:
# - Docker must be installed and running on the machine executing the script.
# - The user must be authenticated to Docker Hub with `docker login` if required.
# 
# Example:
#   ./container_upload.sh v1.0.0

# Set the Docker variables
DOCKER_REGISTRY="uhlaro"
DOCKER_IMAGE_NAME="student_container"
DOCKER_IMAGE_TAG="latest"

# Check if a tag is provided as the first command line argument
if [ -n "$1" ]; then
  DOCKER_IMAGE_TAG="$1"
fi

# Build the Docker image
docker build --progress=plain -t "$DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG" .

# Push the image to the specified Docker Hub registry
docker push "$DOCKER_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG"