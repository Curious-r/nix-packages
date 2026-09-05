# Build vaultix from the pinned source so its build dependencies are owned by
# this repository instead of its development flake.
{
  pkgs,
  sources,
}:
let
  source = sources.vaultix;

  crateVersion =
    file:
    (builtins.fromTOML (builtins.readFile file)).package.version
      or ((builtins.fromTOML (builtins.readFile file)).workspace.package.version);
in
pkgs.rustPlatform.buildRustPackage {
  pname = "vaultix";
  version = "${crateVersion "${source.outPath}/Cargo.toml"}+${
    builtins.substring 0 7 source.revision
  }";

  src = source.outPath;
  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit (source) outPath;
    src = source.outPath;
    hash = "sha256-8quSIQ80PBS210Xm13pcIEhUM2kN+d6wtRd5DDRjrK0=";
  };

  nativeBuildInputs = [ pkgs.rustPlatform.bindgenHook ];
  strictDeps = true;
  doCheck = false;

  meta = {
    mainProgram = "vaultix";
    platforms = pkgs.lib.platforms.linux;
  };
}
