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
  version = "0.3.0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "milieuim";
    repo = "vaultix";
    rev = "8e6331194139366a0398d936b68ff9926ecf3221";
    hash = "sha256-nrha+qCXqJBV7kmvUQB1acc/YzO9YLicR6rdiCaUWYs=";
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
