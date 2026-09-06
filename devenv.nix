{ pkgs, ... }:

{
  cachix.pull = [ "curious" ];

  packages = [
    pkgs.nixfmt
    pkgs.npins
  ];

  languages.nix = {
    enable = true;
    lsp.package = pkgs.nixd;
  };

  enterShell = ''
    echo "nix-packages development environment"
  '';

  enterTest = ''
    nix --version
    npins --version
  '';

  git-hooks.hooks.nixfmt.enable = true;
}
