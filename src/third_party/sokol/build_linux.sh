set -e

build_lib_x64_release() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    # static
    cc -pthread -c -O2 -DNDEBUG -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
    # shared
    cc -pthread -shared -O2 -fPIC -DNDEBUG -DIMPL -D$backend -o $dst.so ../$src.c
}

build_lib_x64_debug() {
    src=$1
    dst=$2
    backend=$3
    echo $dst
    # static
    cc -pthread -c -g -DIMPL -D$backend ../$src.c
    ar rcs $dst.a $src.o
    # shared
    cc -pthread -shared -g -fPIC -DIMPL -D$backend -o $dst.so ../$src.c
}

# x64 + GL
build_lib_x64_release sokol         sokol_log_linux_x64_gl_release SOKOL_GLCORE
build_lib_x64_debug   sokol         sokol_log_linux_x64_gl_debug SOKOL_GLCORE

rm *.o
