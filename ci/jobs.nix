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

  mkJobs =
    system:
    let
      pkgs = import sources.nixpkgs { inherit system; };
      packages = import ../lib { inherit pkgs sources; };
    in
    map (name: {
      name = "Build ${name} (${system})";
      inherit system;
      package = name;
      runsOn = runnerFor.${system};
    }) (builtins.attrNames packages);
in

builtins.concatLists (map mkJobs systems)
