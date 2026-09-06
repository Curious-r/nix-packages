final: _prev: {
  vaultix = final.callPackage ./pkgs/by-name/va/vaultix/package.nix { };

  pam-fido-remote = final.callPackage ./pkgs/by-name/pa/pam-fido-remote/package.nix { };
}
