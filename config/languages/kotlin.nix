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
      server = "kotlin_lsp";
      package = null;
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
