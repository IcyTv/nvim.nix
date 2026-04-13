{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "kotlin";
    filetypes = ["kotlin"];
    description = "Enable Kotlin support";
    lsp = {
      server = "kotlin_language_server";
      package = pkgs.kotlin-language-server;
    };
    format = {
      tool = "ktfmt";
      package = pkgs.ktfmt;
    };
    lint = {
      tool = "ktlint";
      package = pkgs.ktlint;
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--kotlinlang-style"];
        description = "Additional arguments to pass to ktfmt.";
      };
    };

    extraOptions = {
      toolchain = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Kotlin toolchain package (for example pkgs.kotlin) to expose as KOTLIN_HOME for the Kotlin language server.";
      };
      androidSdk = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Android SDK package to expose as ANDROID_SDK_ROOT and ANDROID_HOME for the Kotlin language server.";
      };
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the Kotlin language server. Set this to use a specific server binary or custom environment.";
      };
    };

    extraConfig = cfg: {
      languages.gradle.enable = lib.mkDefault true;

      languages.kotlin = lib.mkIf (cfg.toolchain != null || cfg.androidSdk != null) {
        lsp.command = lib.mkDefault (
          ["env"]
          ++ lib.optional (cfg.toolchain != null) "KOTLIN_HOME=${cfg.toolchain}"
          ++ lib.optional (cfg.androidSdk != null) "ANDROID_SDK_ROOT=${cfg.androidSdk}/share/android-sdk"
          ++ lib.optional (cfg.androidSdk != null) "ANDROID_HOME=${cfg.androidSdk}/share/android-sdk"
          ++ [
            (if cfg.lsp.package != null then lib.getExe cfg.lsp.package else "kotlin-language-server")
          ]
        );
      };

      plugins.lsp.servers.kotlin_language_server = {
        cmd = cfg.lsp.command;
      };

      plugins.conform-nvim.settings.formatters.ktfmt = {
        args = cfg.format.args ++ ["-"];
        stdin = true;
      };
    };
  } {
    inherit pkgs lib config;
  }
