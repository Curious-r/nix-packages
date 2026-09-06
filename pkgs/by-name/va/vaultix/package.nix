{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "vaultix";

  # Upstream has not released the changes we need yet, so this tracks
  # upstream main at a fixed source revision.
  version = "0-unstable-2026-09-06";

  src = fetchFromGitHub {
    owner = "milieuim";
    repo = "vaultix";
    rev = "55a1ab6475fca39c032a9ca37c76c10fa70eb085";
    hash = "sha256-xnf3KQoqLMWIo+JA1M9rt3G/Kd/TNlvOGX7p3DBpOsA=";
  };

  cargoHash = "sha256-8quSIQ80PBS210Xm13pcIEhUM2kN+d6wtRd5DDRjrK0=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  strictDeps = true;
  doCheck = false;

  meta = {
    mainProgram = "vaultix";
    platforms = lib.platforms.linux;
  };
})
