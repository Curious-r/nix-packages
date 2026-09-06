{
  package ? null,
}:

let
  pkgs = import <nixpkgs> { };
  packages = import ../default.nix { inherit pkgs; };

  selectedPackage =
    if package == null then
      throw "No package specified. Use: nix-shell tools/update.nix --argstr package <name>"
    else if !builtins.hasAttr package packages then
      throw "Package `${package}` does not exist."
    else
      packages.${package};

  updateScript =
    selectedPackage.updateScript
      or (throw "Package `${package}` does not have a `passthru.updateScript`.");

  command =
    if builtins.isAttrs updateScript then
      updateScript.command
        or (throw "Package `${package}` has an invalid `updateScript` without `command`.")
    else
      updateScript;

  commandArgs = pkgs.lib.toList command;

  updateName = selectedPackage.name;
  updatePname = selectedPackage.pname or (pkgs.lib.getName selectedPackage);
  updateVersion = selectedPackage.version or (pkgs.lib.getVersion selectedPackage);
in
pkgs.mkShell {
  inputsFrom = [ selectedPackage ];

  shellHook = ''
    export UPDATE_NIX_NAME=${pkgs.lib.escapeShellArg updateName}
    export UPDATE_NIX_PNAME=${pkgs.lib.escapeShellArg updatePname}
    export UPDATE_NIX_OLD_VERSION=${pkgs.lib.escapeShellArg updateVersion}
    export UPDATE_NIX_ATTR_PATH=${pkgs.lib.escapeShellArg package}

    exec ${pkgs.lib.escapeShellArgs commandArgs}
  '';
}
