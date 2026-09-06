{
  description = "Reusable third-party Nix packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );

      overlay = import ./overlay.nix;
    in
    {
      overlays.default = overlay;

      packages = forAllSystems (
        system:
        let
          packageFiles = import ./pkgs/by-name.nix;

          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        builtins.mapAttrs (name: _: pkgs.curious.${name}) packageFiles
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
