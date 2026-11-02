{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
  stdenv,
  mold,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vaultix";

  # Upstream has not released the changes we need yet, so this tracks
  # upstream main at a fixed source revision.
  version = "0.3.0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "milieuim";
    repo = "vaultix";
    rev = "f00717457927f14525728562b7f0ba735ff44de1";
    hash = "sha256-gAUwtxARthE+hVGUmgWSGaWpExC8R9Z6TtJcsB9iWNg=";
  };

  cargoHash = "sha256-8quSIQ80PBS210Xm13pcIEhUM2kN+d6wtRd5DDRjrK0=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux mold;

  strictDeps = true;
  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    mainProgram = "vaultix";
    platforms = lib.platforms.linux;
  };
})
