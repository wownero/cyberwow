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

; in

with nixpkgs;

(buildFHSUserEnv {
  name = "sora-tuner-env"
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
    jdk
    # dart_dev
    gnumake
    gcc
    entr
    androidenv.androidPkgs_9_0.platform-tools


    zlib
    ncurses
    # gcc
    libtool
    autoconf
    automake
    gnum4
    pkgconfig
    cmake
  ]
  ++ android-studio-deps
  )

; multiPkgs = pkgs: (with pkgs;
  [
  ])


; profile = ''
    export ANDROID_HOME=~/SDK/Android/Sdk

    PATH=~/local/sdk/flutter/bin:$PATH
    PATH=~/SDK/Android/android-studio/bin:$PATH

    export ANDROID_NDK_VERSION=r20
    export ANDROID_NDK_ROOT=~/SDK/Android/ndk-archive/android-ndk-$ANDROID_NDK_VERSION
    export NDK=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
    PATH=$NDK/bin:$PATH

    export PATH_NCURSES=${nixpkgs.ncurses5}
    export PATH

    export _JAVA_AWT_WM_NONREPARENTING=1
    export DART_VM_OPTIONS=--root-certs-file=/etc/ssl/certs/ca-certificates.crt

    export ANDROID_NDK_VERSION_WOW=r17c
    export ANDROID_NDK_ROOT_WOW=~/SDK/Android/ndk-archive/android-ndk-$ANDROID_NDK_VERSION_WOW

    exec zsh
  ''

; }).env
