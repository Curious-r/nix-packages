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

  packages = (import ../flake.nix { }).packages;

  isBuildable = system: name: !(packages.${system}.${name}.meta.broken or false);

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
