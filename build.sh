#!/bin/bash
set -e

project_root="$(cd "$(dirname "$0")" && pwd -P)"

flags="-Wno-deprecated-declarations -Wno-int-to-void-pointer-cast -Wno-writable-strings -Wno-dangling-else -Wno-switch -Wno-undefined-internal -Wno-logical-op-parentheses -Wno-nullability-completeness"
libs=""
libs="$libs -framework Cocoa -framework Metal -framework MetalKit -framework QuartzCore -framework CoreAudio -framework AudioUnit"
libs="$libs ../src/third_party/sokol/build/sokol_log_macos_arm64_metal_debug.a"
exe="main"

pushd $project_root

if [ ! -e "./src/third_party/sokol/build/" ]; then
    ./src/third_party/sokol/build_macos.sh
fi

mkdir -p build
pushd build

    if [ ! -e "../src/shaders/triangle.glsl.h" ]; then
        ./tools/sokol-tools-bin/bin/osx_arm64/sokol-shdc -i ../src/shaders/triangle.glsl -o ../src/shaders/triangle.glsl.h -l glsl430:hlsl5:metal_macos -f sokol
    fi

    clang -DDEBUG=1 -I ../src $flags $libs ../src/main.c -o $exe
    ./$exe
    
popd

popd