# Pure package set. This evaluates without the flake, e.g.:
#
#   import ./lib { pkgs = import <nixpkgs> { }; }
#
# Source pins come from ./npins by default and can be overridden explicitly.
{
  pkgs,
  sources ? import ../npins,
}:

{
  vaultix = import ../pkgs/vaultix/package.nix {
    inherit pkgs sources;
  };

  pam-fido-remote = import ../pkgs/pam-fido-remote/package.nix {
    inherit pkgs sources;
  };
}
