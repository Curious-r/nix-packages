let
  packageFiles = import ./pkgs/by-name.nix;
in
final: _prev: builtins.mapAttrs (_name: packageFile: final.callPackage packageFile { }) packageFiles
