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
    # We don't pass filetypes here because we define formatters manually for multiple types
    lsp = {
      server = "ts_ls";
      package = pkgs.typescript-language-server;
    };
    format = {
      tool = "prettier-js"; # Dummy default, we override formatters below
      package = pkgs.nodePackages.prettier;
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

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the prettier command.";
      };
    };

    extraConfig = cfg: {
      plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
        formatters_by_ft = {
          javascript = ["prettier-js"];
          typescript = ["prettier-ts"];
          javascriptreact = ["prettier-js"];
          typescriptreact = ["prettier-ts"];
        };
        formatters = {
          "prettier-js" = {
            command = cfg.format.command;
            args = cfg.format.args ++ ["--parser" "babel"];
          };
          "prettier-ts" = {
            command = cfg.format.command;
            args = cfg.format.args ++ ["--parser" "typescript"];
          };
        };
      };

      plugins.lsp.servers.ts_ls = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
