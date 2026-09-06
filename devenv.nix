{ pkgs, ... }:

{
  packages = with pkgs; [
    git
    npins
  ];

  enterShell = ''
    echo "nix-packages development environment"
  '';

  enterTest = ''
    nix --version
    npins --version
  '';
}
