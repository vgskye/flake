let
  nixpkgs = import <nixpkgs>;
in
  nixpkgs.callPackage (import ./package.nix) {}
