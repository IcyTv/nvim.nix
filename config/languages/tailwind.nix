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
    filetypes = ["tailwind"]; # Note: formatter isn't auto-assigned by mkLang because we customize it below
    lsp = {
      server = "tailwindcss";
      package = pkgs.tailwindcss-language-server;
    };
    format = {
      tool = "prettier-tailwind";
      package = pkgs.nodePackages.prettier;
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
        description = "Configuration for tailwindcss-language-server. See https://github.com/tailwindlabs/tailwindcss-intellisense/blob/master/packages/tailwindcss-language-server/README.md#settings for options.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--plugin=prettier-plugin-tailwindcss" "--parser" "css"];
        description = "Additional arguments to pass to the prettier command for tailwind.";
      };
    };

    extraConfig = cfg: {
      plugins.conform-nvim.settings.formatters."prettier-tailwind".args = cfg.format.args;

      plugins.lsp.servers.tailwindcss = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
