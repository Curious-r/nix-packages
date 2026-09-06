{ pkgs, ... }:

{
  cachix.pull = [ "curious" ];

  packages = [
    pkgs.nixfmt
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
  '';

  git-hooks.hooks.nixfmt.enable = true;
}
