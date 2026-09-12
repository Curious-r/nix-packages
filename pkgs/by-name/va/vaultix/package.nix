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
  version = "0.3.0-unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "milieuim";
    repo = "vaultix";
    rev = "f882a39f249eeac27f884e6ea9618ba106ef0ebe";
    hash = "sha256-XijESLY+NC+KEzcIs+/06Pc6dAW8dJJHgWoFQ8LjomE=";
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
