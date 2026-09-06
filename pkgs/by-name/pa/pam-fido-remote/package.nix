{
  lib,
  stdenv,
  fetchFromCodeberg,
  rustPlatform,
  pkg-config,
  pam,
  libfido2,
  openssl,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pam-fido-remote";
  version = "0.1.5";

  src = fetchFromCodeberg {
    owner = "r-vdp";
    repo = "pam-fido-remote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cpbTJDhg3R7QuS032URn1HyCbzl6K42NBpyLHQrWT48=";
  };

  cargoHash = "sha256-uCt/VIcwRLVfR7A5O0mS5SV2KPpbAg/0oxUJIGJBgdE=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pam
    libfido2
    openssl
  ];

  strictDeps = true;
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  postInstall = ''
    install -Dm0644 \
      "target/${stdenv.hostPlatform.config}/release/libpam_fido_remote.so" \
      "$out/lib/security/pam_fido_remote.so"
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
})
