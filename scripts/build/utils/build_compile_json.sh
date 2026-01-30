#!/bin/bash
# Generate compile_commands.json for IDE support
#
# Usage:
#   ./build_compile_json.sh [target_platform]
#
# This script generates compile_commands.json for better IDE integration
# (e.g., for clangd, ccls, or other language servers)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Error: config.sh not found in $SCRIPT_DIR"
    exit 1
fi

TARGET_PLATFORM=${1:-web}

if ! validate_target_platform "$TARGET_PLATFORM"; then
    log_error "Invalid target platform: $TARGET_PLATFORM"
    exit 1
fi

log_info "Generating compile_commands.json for $TARGET_PLATFORM"

TARGET_IMAGE=$(get_docker_image_name "$TARGET_PLATFORM")
VOLUME_PATH=$(get_volume_path "$PROJECT_DIR")

# Generate compile_commands.json (web requires emsdk env)
if [ "$TARGET_PLATFORM" = "web" ]; then
    SCONS_CMD="source /root/emsdk/emsdk_env.sh && cd /app/godot-cpp && scons platform=web compile_commands.json"
else
    SCONS_CMD="cd /app/godot-cpp && scons platform=$TARGET_PLATFORM compile_commands.json"
fi

docker run --rm \
    -v "$VOLUME_PATH:/app" \
    -w /app \
    "$TARGET_IMAGE" \
    bash -c "$SCONS_CMD"

# Copy to project root and fix paths
if [ -f "$PROJECT_DIR/godot-cpp/compile_commands.json" ]; then
    cp "$PROJECT_DIR/godot-cpp/compile_commands.json" "$PROJECT_DIR"
    
    # Fix paths for Windows if needed
    if is_windows_host; then
        WINDOWS_PROJECT_DIR=$(echo "$PROJECT_DIR" | sed 's|^/\([a-zA-Z]\)|\1:|; s|/|/|g')
        sed -i "s|/app/godot-cpp|$WINDOWS_PROJECT_DIR/godot-cpp|g" "$PROJECT_DIR/compile_commands.json"
    else
        sed -i "s|/app/godot-cpp|$PROJECT_DIR/godot-cpp|g" "$PROJECT_DIR/compile_commands.json"
    fi
    
    log_success "compile_commands.json generated successfully"
    log_info "Location: $PROJECT_DIR/compile_commands.json"
else
    log_error "Failed to generate compile_commands.json"
    exit 1
fi
