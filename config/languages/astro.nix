{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "astro";
    description = "Enable Astro support";
    lsp = {
      server = "astro";
      package = pkgs.astro-language-server;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the Astro language server. Defaults to the configured LSP package or PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for the Astro language server.";
      };
    };

    extraConfig = cfg: {
      languages.typescript.enable = lib.mkDefault true;
      languages.json.enable = lib.mkDefault true;
      languages.css.enable = lib.mkDefault true;
      languages.html.enable = lib.mkDefault true;

      plugins.lsp.servers.astro = lib.mkIf cfg.lsp.enable {
        cmd = cfg.lsp.command;
        settings = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
