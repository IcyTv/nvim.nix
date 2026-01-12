{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "tailwind";
    description = "Enable Tailwind CSS support";
    filetypes = ["tailwind"]; # Note: formatter isn't auto-assigned by mkLang because we customize it
    lsp = {
      server = "tailwindcss";
      package = pkgs.tailwindcss-language-server;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          "files.exclude" = [
            "**/.git/**"
            "**/.svn/**"
            "**/.hg/**"
            "**/CVS/**"
            "**/.DS_Store/**"
            "**/node_modules/**"
            "**/bower_components/**"
            "**/.direnv/**"
          ];
        };
        description = "Configuration for tailwindcss-language-server.";
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
        description = "Additional arguments to pass to the prettierd command.";
      };
    };

    extraConfig = cfg: {
      languages.css.enable = lib.mkDefault true;
      languages.html.enable = lib.mkDefault true;

      # Tailwind is often a plugin for other languages, but if there's a specific 'tailwind' filetype:
      plugins.conform-nvim.settings.formatters_by_ft.tailwind = ["prettierd"];

      plugins.lsp.servers.tailwindcss = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
