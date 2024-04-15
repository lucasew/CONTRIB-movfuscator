{ pkgs ? import <nixpkgs> {}}:
pkgs.pkgsi686Linux.callPackage ./package.nix {}
