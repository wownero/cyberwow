{ pkgs ? import <nixpkgs> {} }:

with pkgs;

# fdroid vm might require a manual enabling of "I/O APIC"

let

  fdroid-python-packages = python-packages: with python-packages; [
    androguard
    clint
    defusedxml
    GitPython
    libcloud
    mwclient
    paramiko
    pillow
    pyasn1
    pyasn1-modules
    python-vagrant
    pyyaml
    qrcode
    requests
    ruamel_yaml
  ]

; python-with-fdroid-packages = pkgs.python3.withPackages fdroid-python-packages

; in

mkShell
{
  buildInputs =
    [
      python-with-fdroid-packages
    ]
; }
