{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkgsCross,
  lld,
  targetArch ? stdenv.hostPlatform.parsed.cpu.name,
}:

let
  targets = {
    x86_64 = {
      rustTarget = "x86_64-unknown-uefi";
      nixPlatform = "x86_64-uefi";
    };

    aarch64 = {
      rustTarget = "aarch64-unknown-uefi";
      nixPlatform = "aarch64-uefi";
    };
  };

  target =
    targets.${targetArch} or (throw "Sprout does not support target architecture ${targetArch}");

  rustPlatform = pkgsCross.${target.rustTarget}.rustPlatform;
in
lib.addMetaAttrs
  {
    platforms = [ target.nixPlatform ];
  }
  (
    rustPlatform.buildRustPackage (finalAttrs: {
      pname = "sprout";
      version = "0.0.30";

      src = fetchFromGitHub {
        owner = "edera-dev";
        repo = "sprout";
        rev = "v${finalAttrs.version}";
        hash = "sha256-8QWzFK2JKvW0Npe+XCVqeuK5x7tOYaCtb3V8L1/Fm+4=";
      };

      cargoHash = "sha256-i7tMmxPLJCWHmq/ofRjmpmoZJdyx54pCkv/mddJecus=";

      # cargo-auditable does not currently handle UEFI/PE targets correctly.
      auditable = false;

      cargoBuildFlags = [
        "--bin"
        "sprout"
        "--config"
        "target.${target.rustTarget}.linker=\"${lib.getExe' lld "lld"}\""
      ];

      doCheck = false;

      # Sprout is a PE/COFF EFI application rather than an ELF executable.
      dontPatchELF = true;
      dontStrip = true;

      installPhase = ''
        runHook preInstall

        install -Dm0755 \
          "target/${target.rustTarget}/release/sprout.efi" \
          "$out/lib/sprout/sprout.efi"

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script { };

      meta = {
        description = "Programmable UEFI bootloader written in Rust";
        homepage = "https://sprout.edera.dev";
        changelog = "https://github.com/edera-dev/sprout/releases/tag/v${finalAttrs.version}";
        license = lib.licenses.asl20;

        # The current nixpkgs LLVM toolchain cannot build the AArch64 UEFI
        # target. Remove this once aarch64-unknown-uefi is supported.
        broken = targetArch == "aarch64";
      };
    })
  )
