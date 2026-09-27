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

  git-hooks.hooks = {
    # Validate GitHub Actions workflow syntax.
    actionlint.enable = true;

    # Keep consistent with the repository formatter.
    nixfmt.enable = true;
    prettier.enable = true;
  };
}
