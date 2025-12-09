{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.typescript;
in {
  options.languages.typescript = {
    enable = lib.mkEnableOption "Enable TypeScript/JavaScript support";
    lsp = {
      enable = lib.mkEnableOption "Enable LSP for TypeScript/JavaScript" // {default = true;};
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for tsserver. See https://github.com/typescript-language-server/typescript-language-server#configuration for options.";
      };
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.typescript-language-server;
        description = "The typescript-language-server package to use";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };
    format = {
      enable = lib.mkEnableOption "Enable formatting for TypeScript/JavaScript" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.nodePackages.prettier;
      };
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the prettier command.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        javascript = ["prettier-js"];
        typescript = ["prettier-ts"];
        javascriptreact = ["prettier-js"];
        typescriptreact = ["prettier-ts"];
      };
      formatters = {
        "prettier-js" = {
          command = lib.getExe cfg.format.package;
          args = cfg.format.args ++ ["--parser" "babel"];
        };
        "prettier-ts" = {
          command = lib.getExe cfg.format.package;
          args = cfg.format.args ++ ["--parser" "typescript"];
        };
      };
    };
    plugins.lsp.servers.tsserver = lib.mkIf cfg.lsp.enable {
      enable = true;
      extraOptions = cfg.lsp.settings;
      package =
        if cfg.lsp.command == null
        then cfg.lsp.package
        else lib.mkForce null;
      cmd = cfg.lsp.command;
    };
  };
}
