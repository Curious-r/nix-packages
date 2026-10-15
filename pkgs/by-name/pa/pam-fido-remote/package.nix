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
  version = "0.2.0";

  src = fetchFromCodeberg {
    owner = "r-vdp";
    repo = "pam-fido-remote";
    rev = "v${finalAttrs.version}";
    hash = "sha256-d9wZq53RNQOKJg0gmXBS4QDJ8a3vk8cD3taQXKbMyIA=";
  };

  cargoHash = "sha256-tHpX8Bn27/BJ0up2KeoZPO+kjScfEXCWhbclhtNfbiQ=";

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
