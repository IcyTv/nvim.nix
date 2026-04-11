{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
  kotlinLspVersion = "262.2310.0";
  kotlinLsp = pkgs.stdenvNoCC.mkDerivation {
    pname = "kotlin-lsp";
    version = kotlinLspVersion;

    src = pkgs.fetchzip {
      url = "https://download-cdn.jetbrains.com/kotlin-lsp/${kotlinLspVersion}/kotlin-lsp-${kotlinLspVersion}-linux-x64.zip";
      hash = "sha256-Bf2qkFpNhQC/Mz563OapmCXeKN+dTrYyQbOcF6z6b48=";
      stripRoot = false;
    };

    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.jdk21
      pkgs.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/kotlin-lsp
      cp -r ./* $out/share/kotlin-lsp

      chmod +x $out/share/kotlin-lsp/kotlin-lsp.sh
      substituteInPlace $out/share/kotlin-lsp/kotlin-lsp.sh \
        --replace-fail 'LOCAL_JRE_PATH="$DIR/jre/Contents/Home"' 'LOCAL_JRE_PATH="${pkgs.jdk21}"' \
        --replace-fail 'LOCAL_JRE_PATH="$DIR/jre"' 'LOCAL_JRE_PATH="${pkgs.jdk21}"'
      makeWrapper $out/share/kotlin-lsp/kotlin-lsp.sh $out/bin/kotlin-lsp

      runHook postInstall
    '';
  };
in
  utils.mkLang {
    name = "kotlin";
    filetypes = ["kotlin"];
    description = "Enable Kotlin support";
    lsp = {
      server = "kotlin_lsp";
      package = kotlinLsp;
    };
    format = {
      tool = "ktfmt";
      package = pkgs.ktfmt;
    };
    lint = {
      tool = "ktlint";
      package = pkgs.ktlint;
    };

    extraOptions = {
      toolchain = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Kotlin toolchain package (for example pkgs.kotlin) to expose as KOTLIN_HOME for the Kotlin language server.";
      };
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the Kotlin language server. Set this to use a specific server binary.";
      };
    };

    extraConfig = cfg: {
      languages.gradle.enable = lib.mkDefault true;

      languages.kotlin = lib.mkIf (cfg.toolchain != null) {
        lsp.command = lib.mkDefault [
          "env"
          "KOTLIN_HOME=${cfg.toolchain}"
          (if cfg.lsp.package != null then lib.getExe cfg.lsp.package else "kotlin-lsp")
        ];
      };

      plugins.lsp.servers.kotlin_lsp = {
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
