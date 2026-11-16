{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "markdown";
    filetypes = ["markdown" "markdown.mdx"];
    description = "Enable Markdown support";
    lsp = {
      server = "marksman";
      package = pkgs.marksman;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };
    lint = {
      tool = "markdownlint-cli2";
      package = pkgs.markdownlint-cli2;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start Marksman. Defaults to the configured LSP package or PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for Marksman.";
      };
    };

    extraConfig = cfg: {
      plugins.lsp.servers.marksman = lib.mkIf cfg.lsp.enable {
        filetypes = ["markdown" "markdown.mdx"];
        cmd = cfg.lsp.command;
        settings = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
