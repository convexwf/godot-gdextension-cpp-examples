#!/bin/bash
# Configuration and utility functions for GDExtension build system

# Godot version
GODOT_VERSION="${GODOT_VERSION:-4.6}"

# Supported host platforms (development platforms)
SUPPORTED_HOST_PLATFORMS=("linux" "macos")

# Supported target platforms (build targets)
# Canonical names = godot-cpp SCons / .gdextension keys (Godot engine uses "linuxbsd" internally; we use "linux")
SUPPORTED_TARGET_PLATFORMS=("linux" "macos" "windows" "web" "android")

# Platform aliases: alternative names accepted from CLI, mapped to canonical name above
# Example: linuxbsd (Godot OS name) -> linux (SCons/gdextension)
normalize_target_platform() {
    case "$1" in
        linuxbsd) echo "linux" ;;
        *)        echo "$1" ;;
    esac
}

# Docker image naming
DOCKER_BASE_IMAGE="godot-fedora-base"
DOCKER_TARGET_IMAGE_PREFIX="godot"

# Project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCKER_DIR="$SCRIPT_DIR/docker"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect host platform
detect_host_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$os" in
        linux*)
            echo "linux"
            ;;
        darwin*)
            echo "macos"
            ;;
        *)
            log_error "Unsupported host platform: $os"
            exit 1
            ;;
    esac
}

# Validate target platform
validate_target_platform() {
    local target=$1
    for platform in "${SUPPORTED_TARGET_PLATFORMS[@]}"; do
        if [ "$platform" == "$target" ]; then
            return 0
        fi
    done
    return 1
}

# Get Dockerfile path for target platform
get_dockerfile_path() {
    local target=$1
    echo "$DOCKER_DIR/Dockerfile.$target"
}

# Get Docker image name for target platform
get_docker_image_name() {
    local target=$1
    echo "${DOCKER_TARGET_IMAGE_PREFIX}-${target}:${GODOT_VERSION}"
}

# Get Docker base image name
get_docker_base_image_name() {
    echo "${DOCKER_BASE_IMAGE}:${GODOT_VERSION}"
}

# Check if running on Windows (Git Bash)
is_windows_host() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WINDIR" ]]; then
        return 0
    fi
    return 1
}

# Get volume mount path (handle Windows path conversion)
get_volume_path() {
    local path=$1
    if is_windows_host; then
        # Convert Windows path to Docker volume path
        echo "/${path//\\//}"
    else
        echo "$path"
    fi
}

# Build SCons command for target platform (platform name passed directly to scons)
# Build SCons command for target platform (platform name passed directly to scons)
build_scons_command() {
    local target=$1
    local build_target=$2  # template_debug or template_release
    
    # Add debug_symbols=yes for template_debug builds
    local extra_flags=""
    if [ "$build_target" = "template_debug" ]; then
        extra_flags=" debug_symbols=yes"
    fi
    
    # Add use_static_cpp=no for Linux to avoid libstdc++ conflicts
    if [ "$target" = "linux" ]; then
        extra_flags="$extra_flags use_static_cpp=no"
    fi
    
    case "$target" in
        web)
            echo "source /root/emsdk/emsdk_env.sh && scons platform=web target=$build_target$extra_flags"
            ;;
        android)
            echo "scons platform=android target=$build_target$extra_flags"
            ;;
        *)
            echo "scons platform=$target target=$build_target$extra_flags"
            ;;
    esac
}
