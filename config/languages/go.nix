{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "go";
    description = "Enable Go support";
    lsp = {
      server = "gopls";
      package = pkgs.gopls;
    };
    format = {
      tool = "gofmt";
      package = pkgs.go;
    };
    lint = {
      tool = "golangcilint";
      package = pkgs.golangci-lint;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start gopls. Defaults to the configured LSP package or PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for gopls.";
      };
    };

    extraFormatOptions.command = lib.mkOption {
      type = lib.types.str;
      default =
        if config.languages.go.format.package != null
        then lib.getExe' config.languages.go.format.package "gofmt"
        else "gofmt";
      description = "Command to run gofmt.";
    };

    extraLintOptions.command = lib.mkOption {
      type = lib.types.str;
      default =
        if config.languages.go.lint.package != null
        then lib.getExe' config.languages.go.lint.package "golangci-lint"
        else "golangci-lint";
      description = "Command to run golangci-lint.";
    };

    extraConfig = cfg: {
      # nvim-lint also invokes golangci-lint from PATH to detect its version.
      extraPackages = lib.mkIf (cfg.lint.enable && cfg.lint.package != null) [cfg.lint.package];

      plugins.lsp.servers.gopls = lib.mkIf cfg.lsp.enable {
        cmd = cfg.lsp.command;
        settings.gopls = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
