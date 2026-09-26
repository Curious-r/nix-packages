{
  pkgs ? import <nixpkgs> { },
}:

let
  packageFiles = import ./pkgs/by-name.nix;
in
pkgs.lib.makeScope pkgs.newScope (
  self: builtins.mapAttrs (_name: packageFile: self.callPackage packageFile { }) packageFiles
)
