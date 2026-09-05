# Build pam-fido-remote from the pinned source so its build dependencies are
# owned by this repository instead of its development flake.
{
  pkgs,
  sources,
}:
let
  source = sources.pam-fido-remote;

  crateVersion =
    file:
    (builtins.fromTOML (builtins.readFile file)).package.version
      or ((builtins.fromTOML (builtins.readFile file)).workspace.package.version);
in
pkgs.rustPlatform.buildRustPackage {
  pname = "pam-fido-remote";
  version = crateVersion "${source.outPath}/Cargo.toml";

  src = source.outPath;
  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit (source) outPath;
    src = source.outPath;
    hash = "sha256-uCt/VIcwRLVfR7A5O0mS5SV2KPpbAg/0oxUJIGJBgdE=";
  };

  nativeBuildInputs = [
    pkgs.pkg-config
    pkgs.rustPlatform.bindgenHook
  ];
  buildInputs = [
    pkgs.pam
    pkgs.libfido2
    pkgs.openssl
  ];
  strictDeps = true;
  doCheck = false;

  postInstall = ''
    install -Dm0644 "target/${pkgs.stdenv.hostPlatform.config}/release/libpam_fido_remote.so" \
      "$out/lib/security/pam_fido_remote.so"
  '';

  meta = {
    platforms = pkgs.lib.platforms.linux;
  };
}
