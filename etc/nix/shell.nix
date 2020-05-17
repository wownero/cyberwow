# Copyright (c) 2019-2020, The Wownero Project
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

let
  nixpkgs = import <nixpkgs> {}

; android-studio-deps = with nixpkgs;
  [
    coreutils
    findutils
    file
    git
    glxinfo
    gn
    gnused
    gnutar
    gtk3
    gnome3.gvfs
    glib
    # gnome3.gconf
    gzip
    fontconfig
    freetype
    libpulseaudio
    libGL
    xorg.libX11
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.setxkbmap
    pciutils
    unzip
    which
    xkeyboard_config
  ]

; ndk-r17c = (nixpkgs.androidenv.composeAndroidPackages
  {
    ndkVersion = "17.2.4988734"
  ; }).ndk-bundle

; ndk-r21b =
    let
      version = "r21b"
    ; in
    nixpkgs.fetchzip
    {
      url = "https://dl.google.com/android/repository/android-ndk-${version}-linux-x86_64.zip"
    ; sha256 = "0shz45b6f2k4lnca8fgghh4cdh53vghfn26cj4mkirkk4cpv1qry"
    ; }

; openssl-source =
    let
      name = "openssl"
    ; version = "1.1.1g"
    ; in
    nixpkgs.fetchurl
    {
      url = "https://www.openssl.org/source/${name}-${version}.tar.gz"
    ; sha256 = "0ikdcc038i7jk8h7asq5xcn8b1xc2rrbc88yfm4hqbz3y5s4gc6x"
    ; }

; iconv-source =
    let
      name = "libiconv"
    ; version = "1.16"
    ; in
    nixpkgs.fetchurl
    {
      url = "http://ftp.gnu.org/pub/gnu/${name}/${name}-${version}.tar.gz"
    ; sha256 = "016c57srqr0bza5fxjxfrx6aqxkqy0s3gkhcg7p7fhk5i6sv38g6"
    ; }

; boost-source =
    let
      name = "boost"
    ; version = "1_71_0"
    ; dot_version = "1.71.0"
    ; in
    nixpkgs.fetchurl
    {
      url =
      "https://dl.bintray.com/boostorg/release/{dot_version}/source/${name}_${version}.tar.bz2"
    ; sha256 = "1vi40mcair6xgm9k8rsavyhcia3ia28q8k0blknwgy4b3sh8sfnp"
    ; }

; sodium-source =
    let
      name = "libsodium"
    ; version = "1.0.18"
    ; in
    nixpkgs.fetchurl
    {
      url = "https://github.com/jedisct1/${name}/archive/${version}.tar.gz"
    ; sha256 = "1x6lll81z4ah732zwpw481qfbzg7yml0nwdgbnd5388jnz3274ym"
    ; }

; randomwow-source =
    let
      name = "RandomWOW"
    ; version = "1.1.6"
    ; in
    nixpkgs.fetchurl
    {
      url = "https://github.com/wownero/${name}/archive/${version}.tar.gz"
    ; sha256 = "1c55y2dwrayh6k1avpchs89gq1mvy5c305h92jm2k48kzhw6a792"
    ; }

; wownero-source =
    nixpkgs.fetchFromGitHub
    {
      owner = "wownero"
    ; repo = "wownero"
    ; rev = "dev-v0.8"
    ; sha256 = "13032pa9wx3h6x860f9iy28vdpkc94wzby153ig7hw4dixjqhs6w"
    ; }

; miniupnp-source =
    nixpkgs.fetchFromGitHub
    {
      owner = "miniupnp"
    ; repo = "miniupnp"
    ; rev = "7800de9"
    ; sha256 = "1f7jgll8lxz2l5lifgqafgx8694x0svgwyz8w8w4cwavm9lmah63"
    ; }

; unbound-source =
    nixpkgs.fetchFromGitHub
    {
      owner = "monero-project"
    ; repo = "unbound"
    ; rev = "9a77c29"
    ; sha256 = "0dmm5pz2yf1lfand9k1c8x0mbrwynkpphh877b8jbavjrwiwsw35"
    ; }

; in

with nixpkgs;

(buildFHSUserEnv {
  name = "cyberwow-env"
; targetPkgs = pkgs: (with pkgs;
  [
    bash
    git
    curl
    unzip
    libGLU
    which

    zsh
    # openjdk10
    # openjdk
    # jetbrains.jdk
    # zulu
    jdk13
    # dart_dev
    gnumake
    gcc
    entr
    # androidenv.androidPkgs_9_0.platform-tools


    zlib
    ncurses
    # gcc
    libtool
    autoconf
    automake
    gnum4
    pkgconfig
    cmake
    ccache
  ]
  ++ android-studio-deps
  )

; multiPkgs = pkgs: (with pkgs;
  [
  ])


; profile = ''
    export ANDROID_HOME=~/SDK/Android/Sdk

    PATH=~/local/sdk/flutter/stable/bin:$PATH
    PATH=~/SDK/Android/android-studio/bin:$PATH
    PATH=~/SDK/Android/Sdk/tools/bin:$PATH

    export ANDROID_NDK_VERSION=r21b
    export ANDROID_NDK_ROOT=${ndk-r21b}
    export NDK=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
    PATH=$NDK/bin:$PATH

    export SRC_OPENSSL=${openssl-source}
    export SRC_ICONV=${iconv-source}
    export SRC_BOOST=${boost-source}
    export SRC_SODIUM=${sodium-source}
    export SRC_RANDOMWOW=${randomwow-source}
    export SRC_MINIUPNP_DIR=${miniupnp-source}
    export SRC_UNBOUND_DIR=${unbound-source}
    export SRC_RAPIDJSON_DIR=${nixpkgs.rapidjson.src}
    export SRC_WOWNERO_DIR=${wownero-source}

    export PATH_NCURSES=${nixpkgs.ncurses5}
    export PATH

    export _JAVA_AWT_WM_NONREPARENTING=1
    export DART_VM_OPTIONS=--root-certs-file=/etc/ssl/certs/ca-certificates.crt

    export ANDROID_NDK_VERSION_WOW=r17c
    export ANDROID_NDK_ROOT_WOW=${ndk-r17c}/libexec/android-sdk/ndk-bundle

    export ZSH_INIT=${nixpkgs.oh-my-zsh}/share/oh-my-zsh/oh-my-zsh.sh
    exec zsh
  ''

; }).env
