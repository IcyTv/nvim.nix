{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "dart";
    description = "Enable Dart support";
    lsp = {
      server = "dartls";
      package = pkgs.dart;
    };
    format = {
      tool = "dart";
      package = pkgs.dart;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the Dart analysis server. Defaults to the configured LSP package or PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for the Dart analysis server. See https://github.com/dart-lang/sdk/blob/main/pkg/analysis_server/tool/lsp_spec/README.md for options.";
      };
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["format" "--output=show"];
        description = "Arguments to pass to `dart` to format a file read from stdin.";
      };
    };

    extraConfig = cfg: {
      plugins.lsp.servers.dartls = lib.mkIf cfg.lsp.enable {
        cmd = cfg.lsp.command;
        settings = cfg.lsp.settings;
      };

      plugins.conform-nvim.settings.formatters.dart = {
        args = cfg.format.args;
        stdin = true;
      };
    };
  } {
    inherit pkgs lib config;
  }
