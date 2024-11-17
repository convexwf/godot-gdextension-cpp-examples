# Godot GDExtension C++ Examples using Docker Compilation Environment

This solution is based on the [mrt-prodz/docker-godot-gdextension-builder](https://github.com/mrt-prodz/docker-godot-gdextension-builder).

You can check more details on the [Godot-GDExtension C++ 环境搭建 (Docker+MinGW/跨平台) | Convexwf's Kirakira Blog](https://blog.convexwf.com/zh/2024/05/godot-gdextension-cpp-environment-using-docker-and-mingw.html).

## Intruction

**[Windows]**

You have to run all the following commands from a Git Bash prompt.

### Build the example

```bash
# execute on windows
bash shell/build.sh windows
# or bash shell/build_windows.sh

# execute on linux
bash shell/build.sh linux
# or bash shell/build_linux.sh
```

## Reference

- [mrt-prodz/docker-godot-gdextension-builder: Building Godot 4 GDExtension C++ example with Docker](https://github.com/mrt-prodz/docker-godot-gdextension-builder)
- [GDExtension C++ example — Godot Engine (stable) documentation in English](https://docs.godotengine.org/en/stable/tutorials/scripting/gdextension/gdextension_cpp_example.html)
- [Godot-GDExtension C++ 环境搭建 (Docker+MinGW/跨平台) | Convexwf's Kirakira Blog](https://blog.convexwf.com/zh/2024/05/godot-gdextension-cpp-environment-using-docker-and-mingw.html)
- [godotengine/build-containers: Godot engine build containers](https://github.com/godotengine/build-containers)
- [godotengine/godot-build-scripts: Build scripts used for official Godot Engine builds with https://github.com/godotengine/build-containers](https://github.com/godotengine/godot-build-scripts/tree/main)
- [zxffffffff/start-godot-cpp: 一个 Godot 脚手架项目，使用源码编译扩展 C++ modules/GDExtension](https://github.com/zxffffffff/start-godot-cpp/tree/main)
- [Compiling for the Web — Godot Engine (stable) documentation in English](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_web.html#gdextension)
- [Building with scons > 4.0 results in an empty compile_commands.json · Issue #54434 · godotengine/godot](https://github.com/godotengine/godot/issues/54434)
