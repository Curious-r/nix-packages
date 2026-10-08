{
  packageNames ? builtins.attrNames (import ../pkgs/by-name.nix),
}:

let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  runnerFor = {
    x86_64-linux = "ubuntu-latest";
    aarch64-linux = "ubuntu-24.04-arm";
  };

  sources = import ../npins;

  packagesFor =
    system:
    let
      pkgs = import sources.nixpkgs {
        inherit system;
        config = {
          allowBroken = false;
          problems.matchers = [
            {
              kind = "broken";
              handler = "warn";
            }
          ];
        };
      };
      scope = import ../default.nix { inherit pkgs; };
    in
    scope.packages scope;

  isBuildable = system: name: !((packagesFor system).${name}.meta.broken or false);

  mkJobs =
    system:
    map (name: {
      name = "Build ${name} (${system})";
      inherit system;
      package = name;
      runsOn = runnerFor.${system};
    }) (builtins.filter (name: isBuildable system name) packageNames);
in

builtins.concatLists (map mkJobs systems)
