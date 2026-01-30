#!/bin/bash
# Main build script for GDExtension C++ project
# 
# Usage:
#   ./build.sh <target_platform> [target_type]
#
# Target platforms (canonical names = godot-cpp SCons / .gdextension; aliases accepted):
#   - linux     : Linux/BSD (alias: linuxbsd)
#   - macos     : macOS
#   - windows   : Windows
#   - web       : Web (Emscripten)
#   - android   : Android
#
# Target types:
#   - template_debug   : Debug export template (default)
#   - template_release : Release export template
#   - editor          : Editor build (if supported)
#   - all             : Build both debug and release (default)
#
# Examples:
#   ./build.sh web template_debug
#   ./build.sh linux
#   ./build.sh windows all

set -e

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Error: config.sh not found in $SCRIPT_DIR"
    exit 1
fi

# Parse arguments and normalize platform (e.g. linuxbsd -> linux)
TARGET_PLATFORM=$(normalize_target_platform "${1:-}")
TARGET_TYPE=${2:-all}

# Validate arguments
if [ -z "$TARGET_PLATFORM" ]; then
    log_error "Target platform is required"
    echo ""
    echo "Usage: $0 <target_platform> [target_type]"
    echo ""
    echo "Target platforms:"
    for platform in "${SUPPORTED_TARGET_PLATFORMS[@]}"; do
        echo "  - $platform"
    done
    echo ""
    echo "Target types: template_debug, template_release, editor, all (default)"
    exit 1
fi

if ! validate_target_platform "$TARGET_PLATFORM"; then
    log_error "Invalid target platform: $TARGET_PLATFORM"
    echo "Supported platforms: ${SUPPORTED_TARGET_PLATFORMS[*]}"
    exit 1
fi

# Detect host platform
HOST_PLATFORM=$(detect_host_platform)
log_info "Host platform: $HOST_PLATFORM"
log_info "Target platform: $TARGET_PLATFORM"
log_info "Target type: $TARGET_TYPE"

# Check if godot-cpp exists
if [ ! -d "$PROJECT_DIR/godot-cpp" ]; then
    log_error "godot-cpp repository not found in $PROJECT_DIR"
    log_info "Please ensure godot-cpp submodule is initialized:"
    log_info "  git submodule update --init --recursive"
    exit 1
fi

# Build base Docker image if needed
BASE_IMAGE=$(get_docker_base_image_name)
if [ -z "$(docker images -q "$BASE_IMAGE" 2>/dev/null)" ]; then
    log_info "Building base Docker image: $BASE_IMAGE"
    docker build -t "$BASE_IMAGE" -f "$DOCKER_DIR/Dockerfile.base" "$DOCKER_DIR"
    
    if [ -z "$(docker images -q "$BASE_IMAGE" 2>/dev/null)" ]; then
        log_error "Failed to build base image: $BASE_IMAGE"
        exit 1
    fi
    log_success "Base image built successfully"
else
    log_info "Base image already exists: $BASE_IMAGE"
fi

# Build target platform Docker image if needed
TARGET_IMAGE=$(get_docker_image_name "$TARGET_PLATFORM")
DOCKERFILE=$(get_dockerfile_path "$TARGET_PLATFORM")

if [ ! -f "$DOCKERFILE" ]; then
    log_error "Dockerfile not found: $DOCKERFILE"
    log_info "Available Dockerfiles:"
    ls -1 "$DOCKER_DIR"/Dockerfile.* 2>/dev/null | sed 's/.*\//  - /' || echo "  (none found)"
    exit 1
fi

if [ -z "$(docker images -q "$TARGET_IMAGE" 2>/dev/null)" ]; then
    log_info "Building target Docker image: $TARGET_IMAGE"
    docker build \
        --build-arg img_version="$GODOT_VERSION" \
        -t "$TARGET_IMAGE" \
        -f "$DOCKERFILE" \
        "$DOCKER_DIR"
    
    if [ -z "$(docker images -q "$TARGET_IMAGE" 2>/dev/null)" ]; then
        log_error "Failed to build target image: $TARGET_IMAGE"
        exit 1
    fi
    log_success "Target image built successfully"
else
    log_info "Target image already exists: $TARGET_IMAGE"
fi

# Determine which targets to build
BUILD_TARGETS=()
case "$TARGET_TYPE" in
    template_debug)
        BUILD_TARGETS=("template_debug")
        ;;
    template_release)
        BUILD_TARGETS=("template_release")
        ;;
    editor)
        BUILD_TARGETS=("editor")
        ;;
    all|*)
        BUILD_TARGETS=("template_debug" "template_release")
        ;;
esac

# Prepare volume path
VOLUME_PATH=$(get_volume_path "$PROJECT_DIR")

# Build the extension
log_info "Building GDExtension for $TARGET_PLATFORM..."
for build_target in "${BUILD_TARGETS[@]}"; do
    log_info "Building target: $build_target"
    
    SCONS_CMD=$(build_scons_command "$TARGET_PLATFORM" "$build_target")
    
    docker run --rm \
        -v "$VOLUME_PATH:/app" \
        -w /app \
        "$TARGET_IMAGE" \
        bash -c "$SCONS_CMD"
    
    if [ $? -eq 0 ]; then
        log_success "Successfully built $build_target for $TARGET_PLATFORM"
    else
        log_error "Failed to build $build_target for $TARGET_PLATFORM"
        exit 1
    fi
done

log_success "Build completed successfully!"
