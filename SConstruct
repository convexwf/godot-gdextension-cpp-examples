#!/usr/bin/env python
import os
import sys

GODOT_PROJECT_NAME = "demo"
env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

# env['platform'] = windows
# env['target'] = template_debug
# env['suffix'] = .windows.template_debug.x86_64
# env['SHLIBSUFFIX'] = .dll

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "{}/gdextension/libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            GODOT_PROJECT_NAME, env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "{}/gdextension/libgdexample{}{}".format(GODOT_PROJECT_NAME, env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
