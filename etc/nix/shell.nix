let
#   moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz)
# # ; nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; }

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
    zlib
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
    dart_dev
    gnumake
    entr
    androidenv.androidPkgs_9_0.platform-tools
  ]
  ++ android-studio-deps
  )

; multiPkgs = pkgs: (with pkgs;
  [
  ])

; profile = ''
    export ANDROID_HOME=~/SDK/Android/Sdk

    PATH=~/scm/flutter/vendor/flutter/bin:$PATH
    PATH=~/SDK/Android/android-studio/bin:$PATH

    export ANDROID_NDK_ROOT=~/SDK/Android/ndk-archive/android-ndk-r20
    export NDK=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64
    PATH=$NDK/bin:$PATH

    export PATH

    export _JAVA_AWT_WM_NONREPARENTING=1

    exec zsh
  ''

; }).env
