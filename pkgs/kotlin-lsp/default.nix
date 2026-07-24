{
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  jdk,
  stdenv,
  gnutar,
  gzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kotlin-lsp";
  version = "262.8190.0";

  src = fetchurl {
    url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${finalAttrs.version}/kotlin-server-${finalAttrs.version}.tar.gz";
    hash = "sha256-i0xw6VBlQg54Z8mar58Y4LTnYxHsRT5MGjnj9q53TL8=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    gnutar
    gzip
  ];

  buildInputs = [
    jdk
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    tar xzf "$src" -C "$out/share" --strip-components=1 --exclude='jbr'

    chmod +x $out/share/bin/intellij-server $out/share/kotlin-lsp.sh
    makeWrapper $out/share/bin/intellij-server $out/bin/kotlin-language-server \
      --set-default JAVA_HOME "${jdk}" \
      --set-default JDK_HOME "${jdk}"

    runHook postInstall
  '';
})
