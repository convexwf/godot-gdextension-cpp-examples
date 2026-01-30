# GDExtension Build System

This directory contains the build system for compiling GDExtension C++ extensions for multiple target platforms.

## Concepts

### Host Platform (开发平台)
The platform where you develop and run the build scripts:
- **linux**: Linux (Ubuntu/Debian/Fedora)
- **macos**: macOS

### Target Platform (目标平台)
The platform where the compiled extension will run (canonical names = godot-cpp/.gdextension; aliases accepted):
- **linux**: Linux/BSD (alias: `linuxbsd`, Godot’s internal name)
- **macos**: macOS
- **windows**: Windows
- **web**: Web (Emscripten/WebAssembly)
- **android**: Android

## Quick Start

### Build for a specific platform

```bash
# Build for Web (recommended for development verification)
./build.sh web template_debug

# Build for Linux/BSD (both debug and release; linuxbsd also accepted)
./build.sh linux

# Build for Windows
./build.sh windows

# Build only release template
./build.sh web template_release
```

### Generate compile_commands.json for IDE support

```bash
./utils/build_compile_json.sh web
```

## Directory Structure

```
scripts/build/
├── README.md              # This file
├── build.sh              # Main build script
├── config.sh             # Configuration and utilities
├── docker/               # Docker images for each target platform
│   ├── Dockerfile.base   # Base image with common tools
│   ├── Dockerfile.linux
│   ├── Dockerfile.macos
│   ├── Dockerfile.windows
│   ├── Dockerfile.web
│   └── Dockerfile.android
└── utils/                 # Utility scripts
    └── build_compile_json.sh
```

## Build Targets

The build system supports different target types:

- **template_debug**: Debug export template (default)
- **template_release**: Release export template
- **editor**: Editor build (if supported by platform)
- **all**: Build both debug and release (default)

## Platform-Specific Notes

### Linux/BSD (linux; alias linuxbsd)
Uses native GCC toolchain. No special requirements. Use `./build.sh linux` or `./build.sh linuxbsd`.

### macOS (macos)
**Note**: macOS builds typically require:
- macOS host system, OR
- Cross-compilation tools (osxcross)
- macOS SDK

The current Docker setup is a placeholder. For actual macOS builds, you may need to:
1. Build on macOS host directly
2. Use osxcross for cross-compilation from Linux

### Windows (windows)
Uses MinGW-w64 for cross-compilation. Includes:
- MinGW-w64 toolchain
- LLVM-MinGW for better compatibility

### Web (web)
Uses Emscripten SDK for WebAssembly compilation. The Docker image includes:
- Emscripten 3.1.64
- Automatic environment setup

### Android (android)
Requires Android NDK. The Dockerfile is a basic setup - you may need to:
1. Download Android NDK
2. Mount it as a volume, or
3. Install it in the Docker image

## Configuration

Edit `config.sh` to customize:
- Godot version (`GODOT_VERSION`)
- Docker image names
- Build options

## Docker Images

The build system uses Docker images to ensure consistent build environments:

1. **Base image** (`godot-fedora-base`): Contains common tools (SCons, build tools)
2. **Target images** (`godot-<platform>`): Platform-specific toolchains

Images are built automatically on first use. To rebuild:

```bash
# Rebuild base image
docker build -t godot-fedora-base:4.6 -f docker/Dockerfile.base docker/

# Rebuild target image
docker build --build-ARG img_version=4.6 -t godot-linux:4.6 -f docker/Dockerfile.linux docker/
```

## Troubleshooting

### Docker image not found
The build script will automatically build missing images. If you encounter issues:
1. Check Docker is running
2. Verify Dockerfile exists for your target platform
3. Check Docker build logs

### Path issues on Windows
The build script automatically handles Windows path conversion when running in Git Bash.

### Build failures
1. Ensure `godot-cpp` submodule is initialized:
   ```bash
   git submodule update --init --recursive
   ```
2. Check Docker has enough resources (CPU, memory)
3. Verify target platform is supported

## Reference

- [Godot Build System Documentation](https://docs.godotengine.org/zh-cn/4.x/engine_details/development/compiling/introduction_to_the_buildsystem.html)
- [GDExtension C++ Example](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/gdextension_cpp_example.html)
