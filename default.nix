{
  pkgs ? import <nixpkgs> { },
}:

let
  packageFiles = import ./pkgs/by-name.nix;
in
builtins.mapAttrs (_name: packageFile: pkgs.callPackage packageFile { }) packageFiles
