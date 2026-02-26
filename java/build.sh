#!/bin/bash
set -euo pipefail

# =====================================================
# Script to build the STA Java project using Docker
# =====================================================
# This script uses Docker for a fully reproducible build environment. The 
# Dockerfile already includes Maven and Java (JDK), so no local setup is needed. 
# The final jar-with-dependencies will be copied to ../inst/java on the host.
# =====================================================

# Name of the Docker image to build
IMAGE_NAME="sta-jar"

# Directory on the host where jars will be copied
HOST_JAR_DIR="$PWD/../inst/java/"

# Create the output directory if it doesn't exist
mkdir -p "$HOST_JAR_DIR"

echo "Building Docker image: $IMAGE_NAME..."
docker build . -t "$IMAGE_NAME"

echo "Running container to extract jar files..."
docker run --rm -v "$HOST_JAR_DIR":/host "$IMAGE_NAME" sh -c 'cp /out/*.jar /host/'

echo "Done! Jar files are available in: $HOST_JAR_DIR"