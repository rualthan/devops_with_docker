#!/bin/sh
# Exit immediately if a command exits with a non-zero status.
set -e
usage() {
  echo "Usage: $0 <user/repo> <user/image>"
  exit 1
}


if [ $# -ne 2 ]; then
    usage
fi

REPO=$1
IMAGE=$2
TMP_DIR=$(mktemp -d)

cleanup() {
    echo "Cleaning up temporary directory..."
    rm -rf "$TMP_DIR"
}

# Ensure cleanup is called on script exit
trap cleanup EXIT

# Clone the repository and build the Docker image
echo "Cloning repository $REPO..."
git clone https://github.com/$REPO.git $TMP_DIR

# Change to the cloned directory
cd $TMP_DIR

# Build and push the Docker image
echo "Building Docker image $IMAGE..."
docker build -t $IMAGE .

# Login to Docker registry
echo "Logging in to Docker registry..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Push the Docker image to the registry
echo "Pushing Docker image $IMAGE to registry..."
docker push $IMAGE