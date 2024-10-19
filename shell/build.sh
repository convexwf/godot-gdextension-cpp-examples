#!/bin/bash

# This script is used to build the project.
## Usage: ./build.sh [windows|linux|web]

BUILD_PLATFORM="windows"
TARGET_PLATFORM=$1
GODOT_CPP_VERSION=4.3

if [ -z "$TARGET_PLATFORM" ]; then
    echo "Usage: $0 [windows|linux|web]"
    exit 1
fi

if [ "$TARGET_PLATFORM" != "windows" ] && [ "$TARGET_PLATFORM" != "linux" ] && [ "$TARGET_PLATFORM" != "web" ]; then
    echo "Error: TARGET_PLATFORM must be 'windows' or 'linux'"
    exit 1
fi

set -e

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)

echo "Building project in $PROJECT_DIR"

# Check if the godot-cpp repository exists, if not, clone it
if [ ! -d $PROJECT_DIR/godot-cpp ]; then
    echo "Error: godot-cpp repository not found in $PROJECT_DIR"
    exit 1
fi

# Check if the base image is already built, if not, build it
if [ ! "$(docker images -q godot-fedora-base:4.3 2> /dev/null)" ]; then
    echo "Building base image godot-fedora-base:4.3"
    cd $SCRIPT_DIR && docker build -t godot-fedora-base:4.3 -f Dockerfile.base .

    # Check if the base image was built successfully
    if [ ! "$(docker images -q godot-fedora-base:4.3 2> /dev/null)" ]; then
        echo "Error: Failed to build base image godot-fedora-base:4.3"
        exit 1
    fi
fi

# Build the docker image for the target platform
build_docker_image() {
    local platform=$1
    local dockerfile=$2

    # Check if the docker image is already built, if not, build it
    if [ ! "$(docker images -q godot-${platform}:$GODOT_CPP_VERSION 2> /dev/null)" ]; then
        echo "Building godot-${platform}:$GODOT_CPP_VERSION"
        cd $SCRIPT_DIR && docker build --build-arg img_version=$GODOT_CPP_VERSION -t godot-${platform}:$GODOT_CPP_VERSION -f $dockerfile .

        # Check if the docker image was built successfully
        if [ ! "$(docker images -q godot-${platform}:$GODOT_CPP_VERSION 2> /dev/null)" ]; then
            echo "Error: Failed to build godot-${platform}:$GODOT_CPP_VERSION"
            exit 1
        fi
    fi
}
build_docker_image $TARGET_PLATFORM Dockerfile.$TARGET_PLATFORM

# Check if we are running on Windows, if so, we need to add a slash to the project directory
AUTO_SLASH=""
if [ "$BUILD_PLATFORM" == "windows" ]; then
    AUTO_SLASH="/"
fi

# Run the docker container to build the extension
exec_docker_container() {
    local platform=$1
    echo "Building extension for platform $platform"

    # For web platform, we need to activate emscripten environment first
    if [ "$platform" == "web" ]; then
        docker run --rm \
            -v ${AUTO_SLASH}${PROJECT_DIR}:/app \
            godot-${platform}:$GODOT_CPP_VERSION \
            bash -c "source /root/emsdk/emsdk_env.sh && cd /app && scons platform=web dlink_enabled=yes target=template_debug"
    else
        docker run --rm \
            -v ${AUTO_SLASH}${PROJECT_DIR}:/app \
            godot-${platform}:$GODOT_CPP_VERSION \
            bash -c "cd /app && scons platform=${platform}"
    fi
}
exec_docker_container $TARGET_PLATFORM
