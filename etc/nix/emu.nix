with import <nixpkgs> {};

androidenv.emulateApp {
  name = "emulate-flutter-app";
  platformVersion = "28";
  abiVersion = "x86_64";
  enableGPU = true;
}
