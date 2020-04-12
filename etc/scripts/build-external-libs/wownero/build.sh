#!/bin/bash

# Copyright (c) 2019, The Wownero Project
# Copyright (c) 2014-2019, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

source etc/scripts/build-external-libs/env.sh

build_root=$BUILD_ROOT
src_root=$BUILD_ROOT_SRC

build_root_wow=$BUILD_ROOT_WOW

name=wownero

cd $src_root/${name}

archs=(arm64)
for arch in ${archs[@]}; do
    extra_cmake_flags=""
    case ${arch} in
        "arm")
            target_host=arm-linux-androideabi
            ;;
        "arm64")
            target_host=aarch64-linux-android
            ;;
        "x86_64")
            target_host=x86_64-linux-android
            ;;
        *)
            exit 16
            ;;
    esac

    # PREFIX=$build_root/build/${name}/$arch
    PREFIX=$build_root/build/$arch
    echo "building for ${arch}"

    mkdir -p $PREFIX/dlib/
    rm -f $PREFIX/dlib/libtinfo.so.5
    ln -s $PATH_NCURSES/lib/libncursesw.so.5 $PREFIX/dlib/libtinfo.so.5

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PREFIX/dlib
    export TOOLCHAIN_DIR=`realpath $build_root_wow/tool/${arch}`
    export PATH=$PATH:$build_root/host/bin

    mkdir -p build/release
    pushd .
    cd build/release
    (
        CMAKE_INCLUDE_PATH="${PREFIX}/include" \
          CMAKE_LIBRARY_PATH="${PREFIX}/lib" \
          CC=aarch64-linux-android-clang \
          CXX=aarch64-linux-android-clang++ \
          cmake \
          -D BUILD_TESTS=OFF \
          -D ARCH="armv8-a" \
          -D STATIC=ON \
          -D BUILD_64=ON \
          -D CMAKE_BUILD_TYPE=release \
          -D ANDROID=true \
          -D INSTALL_VENDORED_LIBUNBOUND=ON \
          -D BUILD_TAG="android-armv8" \
          -D CMAKE_SYSTEM_NAME="Android" \
          -D CMAKE_ANDROID_STANDALONE_TOOLCHAIN="${TOOLCHAIN_DIR}" \
          -D CMAKE_ANDROID_ARCH_ABI="arm64-v8a" \
          -D MANUAL_SUBMODULES=ON \
          ../.. && make -j${NPROC}
    )
    popd

done

exit 0
