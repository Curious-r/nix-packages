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
          scope = import ./default.nix {
            pkgs = import sources.nixpkgs {
              inherit system;
            };
          };
        in
        scope.packages scope
      );

      formatter = import ./tools/formatter.nix { inherit sources systems; };
    };
}
