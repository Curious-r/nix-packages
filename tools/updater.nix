{
  package ? null,
}:

let
  sources = import ../npins;
  pkgs = import sources.nixpkgs { };
  packages = import ../default.nix { inherit pkgs; };

  selectedPackage =
    if package == null then
      throw "No package specified. Use: nix-shell tools/updater.nix --argstr package <name>"
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

  updateCommand = pkgs.lib.escapeShellArgs commandArgs;
in
pkgs.mkShell {
  shellHook = ''
    unset shellHook

    exec ${pkgs.coreutils}/bin/env \
      UPDATE_NIX_NAME=${pkgs.lib.escapeShellArg updateName} \
      UPDATE_NIX_PNAME=${pkgs.lib.escapeShellArg updatePname} \
      UPDATE_NIX_OLD_VERSION=${pkgs.lib.escapeShellArg updateVersion} \
      UPDATE_NIX_ATTR_PATH=${pkgs.lib.escapeShellArg package} \
      ${pkgs.nix}/bin/nix-shell \
      ${pkgs.path}/shell.nix \
      --run ${pkgs.lib.escapeShellArg updateCommand}
  '';
}
