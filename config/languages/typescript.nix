{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "typescript";
    description = "Enable TypeScript/JavaScript support";
    # We define formatters manually for multiple types, but all use prettierd
    lsp = {
      server = "ts_ls";
      package = pkgs.typescript-language-server;
    };
    format = {
      tool = "prettierd"; 
      package = pkgs.prettierd;
    };
    lint = {
      tool = "eslint_d";
      package = pkgs.eslint_d;
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for tsserver. See https://github.com/typescript-language-server/typescript-language-server#configuration for options.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };

    extraConfig = cfg: {
      languages.json.enable = lib.mkDefault true;

      plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
        formatters_by_ft = {
          javascript = ["prettierd"];
          typescript = ["prettierd"];
          javascriptreact = ["prettierd"];
          typescriptreact = ["prettierd"];
        };
        # No custom formatters needed, conform uses prettierd defaults
      };

      plugins.lsp.servers.ts_ls = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
