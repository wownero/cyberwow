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

name=zlib
version=1.2.11

cd $src_root/${name}-${version}

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

    export CC=clang
    export CXX=clang++

    (
        PATH=$build_root/tool/$arch/$target_host/bin:$build_root/tool/$arch/bin:$PATH; \
            ./configure \
            --prefix=${PREFIX} \
            --static \
            && make -j${NPROC} && make install && make clean \
    )

done

exit 0
