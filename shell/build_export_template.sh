#!/bin/bash

platform="windows"
BUILD_PLATFORM="web"

GODOT_ENGINE_DIR="/d/workspace/godot/godot_engine"
GODOT_ENGINEP_VERSION="4.3"

# Check if the Godot engine directory exists
if [ ! -d "$GODOT_ENGINE_DIR" ]; then
    echo "The Godot engine directory does not exist: $GODOT_ENGINE_DIR"
    exit 1
fi

# Check if the image is already built, if not, exit
if [ ! "$(docker images -q godot-${BUILD_PLATFORM}:$GODOT_ENGINEP_VERSION 2> /dev/null)" ]; then
    echo "Error: Docker image godot-${BUILD_PLATFORM}:$GODOT_ENGINEP_VERSION not found"
    exit 1
fi

# Check if we are running on Windows, if so, we need to add a slash to the project directory
AUTO_SLASH=""
if [ "$platform" == "windows" ]; then
    AUTO_SLASH="/"
fi

# Generate the export templates
docker run --rm \
    -v ${AUTO_SLASH}${GODOT_ENGINE_DIR}:/app \
    godot-${BUILD_PLATFORM}:$GODOT_ENGINEP_VERSION \
    bash -c "source /root/emsdk/emsdk_env.sh && scons platform=$BUILD_PLATFORM dlink_enabled=yes target=template_release && scons platform=$BUILD_PLATFORM dlink_enabled=yes target=template_debug"
