{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
  gradleLsp = pkgs.stdenvNoCC.mkDerivation {
    pname = "gradle-language-server";
    version = pkgs.vscode-extensions.vscjava.vscode-gradle.version;
    src = pkgs.vscode-extensions.vscjava.vscode-gradle;
    dontUnpack = true;

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/share/gradle-language-server

      if [ -f "$src/share/vscode/extensions/vscjava.vscode-gradle/lib/ls-fat-jar.jar" ]; then
        cp "$src/share/vscode/extensions/vscjava.vscode-gradle/lib/ls-fat-jar.jar" \
          "$out/share/gradle-language-server/gradle-language-server.jar"
      else
        cp "$src/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-language-server.jar" \
          "$out/share/gradle-language-server/gradle-language-server.jar"
      fi

      makeWrapper "${pkgs.jdk21}/bin/java" "$out/bin/gradle-language-server" \
        --add-flags "-cp $out/share/gradle-language-server/gradle-language-server.jar com.microsoft.gradle.GradleLanguageServer"

      runHook postInstall
    '';
  };
in
  utils.mkLang {
    name = "gradle";
    filetypes = ["groovy" "kotlin"];
    description = "Enable Gradle support";
    lsp = {
      server = "gradle_ls";
      package = gradleLsp;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start gradle_ls. Set when providing your own gradle language server.";
      };
    };

    extraConfig = cfg: {
      extraPackages = [pkgs.gradle];

      plugins.lsp.servers.gradle_ls = lib.mkIf cfg.lsp.enable {
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
