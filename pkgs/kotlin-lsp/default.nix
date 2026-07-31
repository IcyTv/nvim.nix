{
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  stdenv,
  gnutar,
  gzip,
  libX11,
  libXext,
  libXi,
  libXrender,
  libXtst,
  libxkbcommon,
  wayland,
  freetype,
  alsa-lib,
  zlib,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kotlin-language-server";
  version = "262.9593.0";

  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}.tar.gz";
    hash = "sha256-LZnY4Zj75KqPRIHjd5lyTOlIA7TqEqYLQWBA4/zXzF4=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    gnutar
    gzip
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    libX11
    libXext
    libXi
    libXrender
    libXtst
    libxkbcommon
    wayland
    freetype
    alsa-lib
    zlib
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    tar xzf "$src" -C "$out/share" --strip-components=1

    chmod +x $out/share/bin/intellij-server $out/share/kotlin-lsp.sh
    makeWrapper $out/share/bin/intellij-server $out/bin/kotlin-language-server \
      --add-flags "--stdio" \
      --set-default JAVA_HOME "$out/share/jbr" \
      --set-default JDK_HOME "$out/share/jbr"

    runHook postInstall
  '';

  meta.mainProgram = "kotlin-language-server";
})
