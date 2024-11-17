#!/bin/bash

platform="windows"
BUILD_PLATFORM="windows"
GODOT_CPP_VERSION="4.3"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_DIR=$(cd $SCRIPT_DIR/..; pwd)

# Check if we are running on Windows, if so, we need to add a slash to the project directory
AUTO_SLASH=""
if [ "$BUILD_PLATFORM" == "windows" ]; then
    AUTO_SLASH="/"
fi

# Generate compile_commands.json
docker run --rm \
    -v ${AUTO_SLASH}${PROJECT_DIR}:/app \
    godot-${platform}:$GODOT_CPP_VERSION \
    bash -c "cd /app/godot-cpp && scons platform=windows compile_commands.json"

# Copy compile_commands.json to the project root
# and replace the absolute paths with relative paths
cp $PROJECT_DIR/godot-cpp/compile_commands.json $PROJECT_DIR
WINDOWS_PROJECT_DIR=$(echo "$PROJECT_DIR" | sed 's|^/\([a-zA-Z]\)|\1:|; s|/|/|g')
sed -i "s|/app/godot-cpp|$WINDOWS_PROJECT_DIR/godot-cpp|g" $PROJECT_DIR/compile_commands.json
