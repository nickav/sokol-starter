set -e

build_lib_arm64_release() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -O2 -x objective-c -arch arm64 -DNDEBUG -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
}

build_lib_arm64_debug() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -g -x objective-c -arch arm64 -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
}

build_lib_x64_release() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -O2 -x objective-c -arch x86_64 -DNDEBUG -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
}

build_lib_x64_debug() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    MACOSX_DEPLOYMENT_TARGET=10.13 cc -c -g -x objective-c -arch x86_64 -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
}

project_root="$(cd "$(dirname "$0")" && pwd -P)"
pushd $project_root
mkdir -p build

pushd build

# ARM + Metal
build_lib_arm64_release sokol sokol_log_macos_arm64_metal_release SOKOL_METAL
build_lib_arm64_debug   sokol sokol_log_macos_arm64_metal_debug SOKOL_METAL

# x64 + Metal
build_lib_x64_release sokol   sokol_log_macos_x64_metal_release SOKOL_METAL
build_lib_x64_debug   sokol   sokol_log_macos_x64_metal_debug SOKOL_METAL

rm *.o

popd
popd