let
  baseDirectory = ./by-name;
  entries = builtins.readDir baseDirectory;

  shards = builtins.filter (name: entries.${name} == "directory") (builtins.attrNames entries);
in
builtins.foldl' (
  packages: shard:
  let
    shardDirectory = baseDirectory + "/${shard}";
    entries = builtins.readDir shardDirectory;

    packageDirectories = builtins.filter (name: entries.${name} == "directory") (
      builtins.attrNames entries
    );

    newPackages = builtins.listToAttrs (
      map (name: {
        inherit name;
        value = shardDirectory + "/${name}/package.nix";
      }) packageDirectories
    );

    duplicateNames = builtins.filter (name: builtins.hasAttr name packages) (
      builtins.attrNames newPackages
    );
  in
  assert
    duplicateNames == [ ]
    || throw "Duplicate package names: ${builtins.concatStringsSep ", " duplicateNames}";
  packages // newPackages
) { } shards
