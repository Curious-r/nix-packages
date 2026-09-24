{
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  stdenvNoCC,
  clang,
  gotools,
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
let
  pnpm = pnpm_10;

  pname = "daed";
  version = "2.1.1";
  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "daed";
    tag = "v${version}";
    hash = "sha256-F8Q97sGA4sMgupb31+nFT55sdx/Jr1mgwOjb45o9hlc=";
    fetchSubmodules = true;
  };

  frontend = stdenvNoCC.mkDerivation {
    inherit pname version src;

    pnpmDeps = fetchPnpmDeps {
      inherit
        pname
        version
        src
        pnpm
        ;
      fetcherVersion = 3;
      hash = "sha256-nr/MJQ/i0EHE+u24shqGgU4oEN/wLEtcn7UWVU+hsjA=";
    };

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    strictDeps = true;
    __structuredAttrs = true;

    buildPhase = ''
      runHook preBuild

      pnpm build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R apps/web/dist/* $out

      runHook postInstall
    '';
  };
in
buildGoModule {
  inherit pname version src;

  sourceRoot = "${src.name}/wing";

  vendorHash = "sha256-+YQ/Ia54N/QKwd9p4AePg3CMjQvc4mFE1EcA/JPc8Po=";
  proxyVendor = true;

  # The upstream build is handled by `make bundle` instead of buildGoModule's default phases.
  doCheck = false;

  nativeBuildInputs = [
    clang
    gotools
  ];

  hardeningDisable = [ "zerocallusedregs" ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace-fail /bin/bash /bin/sh

    substituteInPlace graphql/service/config/global/global.go \
      --replace-fail \
        'go run -mod=mod golang.org/x/tools/cmd/goimports -w generated_resolver.go generated_input.go' \
        'goimports -w generated_resolver.go generated_input.go'
  '';

  buildPhase = ''
    runHook preBuild

    mkdir dist
    cp -r ${frontend}/* dist
    chmod -R 755 dist

    make CFLAGS="-D__REMOVE_BPF_PRINTK -fno-stack-protector -Wno-unused-command-line-argument" \
      NOSTRIP=y \
      WEB_DIST=dist \
      AppName=daed \
      VERSION=${version} \
      OUTPUT=$out/bin/daed \
      bundle

    runHook postBuild
  '';

  postInstall = ''
    install -Dm444 $src/install/daed.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/daed.service \
      --replace-fail /usr/bin $out/bin
  '';

  passthru = {
    inherit frontend;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Modern dashboard with dae";
    homepage = "https://github.com/daeuniverse/daed";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "daed";
  };
}
