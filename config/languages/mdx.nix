{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "mdx";
    description = "Enable MDX support";
    lsp = {
      server = "mdx_analyzer";
      package = pkgs.mdx-language-server;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the MDX language server. Defaults to the configured LSP package or PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for the MDX language server.";
      };
    };

    extraConfig = cfg: {
      filetype.extension.mdx = "mdx";
      extraConfigLua = ''
        vim.treesitter.language.register('markdown', 'mdx')
      '';

      plugins.lsp.servers.mdx_analyzer = lib.mkIf cfg.lsp.enable {
        filetypes = ["mdx"];
        cmd = cfg.lsp.command;
        settings = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
