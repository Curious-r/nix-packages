let
  packageFiles = import ./pkgs/by-name.nix;
in
final: _prev: {
  curious = builtins.mapAttrs (_name: packageFile: final.callPackage packageFile { }) packageFiles;
}
