let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  runnerFor = {
    x86_64-linux = "ubuntu-latest";
    aarch64-linux = "ubuntu-24.04-arm";
  };

  packageNames = builtins.attrNames (import ../pkgs/by-name.nix);

  mkJobs =
    system:
    map (name: {
      name = "Build ${name} (${system})";
      inherit system;
      package = name;
      runsOn = runnerFor.${system};
    }) packageNames;
in

builtins.concatLists (map mkJobs systems)
