{
  description = "Reusable third-party Nix packages";

  outputs =
    { self }:
    let
      sources = import ./npins;

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

      pkgsFor = system: import sources.nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system: import ./lib { pkgs = pkgsFor system; });

      overlays.default = import ./overlays;

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
