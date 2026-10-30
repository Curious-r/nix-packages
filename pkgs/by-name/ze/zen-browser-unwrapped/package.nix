{
  autoPatchelfHook,
  fetchurl,
  lib,
  patchelfUnstable,
  stdenv,
  wrapGAppsHook3,
  adwaita-icon-theme,
  alsa-lib,
  curl,
  dbus-glib,
  gtk3,
  libva,
  libxtst,
  pciutils,
}:

let
  version = "1.24b";
  binaryName = "zen";
  applicationName = "Zen Browser";
  libName = "zen-${version}";

  sources = {
    x86_64-linux = {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
      hash = "sha256-Mj8mguc+OCR6UfvMdeVijtK7m0BNsAz5zxavMpqRb64=";
    };

    aarch64-linux = {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-aarch64.tar.xz";
      hash = "sha256-7C/0CoCdaY0ZDlijK2JztWTBr5wk2xskQjJ+q33Nb2Y=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "zen-browser is unsupported on ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation (finalAttrs: {
  pname = "zen-browser-unwrapped";
  inherit version;

  src = fetchurl source;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = [
    gtk3
    alsa-lib
    adwaita-icon-theme
    dbus-glib
    libxtst
  ];

  runtimeDependencies = [
    curl
    libva.out
    pciutils
  ];

  # Firefox uses "relrhack" to manually process relocations from a fixed offset.
  patchelfFlags = [ "--no-clobber-old-sections" ];

  installPhase = ''
    mkdir -p "$out/lib/${libName}" "$out/bin"

    cp -a . "$out/lib/${libName}/"
    ln -s "$out/lib/${libName}/${binaryName}" "$out/bin/${binaryName}"
  '';

  passthru = {
    inherit applicationName binaryName libName;

    # Current wrapFirefox uses these names for optional runtime dependencies.
    withFFmpeg = true;
    withGSSAPI = true;
    withPipewire = true;

    inherit gtk3;

    updateScript = ./update.sh;
  };

  meta = {
    description = "Privacy-focused web browser based on Firefox";
    homepage = "https://zen-browser.app";
    license = lib.licenses.mpl20;
    mainProgram = binaryName;
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
