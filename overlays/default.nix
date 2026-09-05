# Convenience overlay exposing the package set from lib/default.nix.
# The pure Nix API in lib/default.nix stays the canonical implementation.
final: _prev:

let
  packages = import ../lib { pkgs = final; };
in
{
  inherit (packages)
    vaultix
    pam-fido-remote
    ;
}
