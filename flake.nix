{
  description = "Reusable third-party Nix packages";

  outputs =
    _:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      sources = import ./npins;

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

          pkgs = import sources.nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };
        in
        builtins.mapAttrs (name: _: pkgs.curious.${name}) packageFiles
      );

      formatter = import ./tools/formatter.nix { inherit sources systems; };
    };
}
