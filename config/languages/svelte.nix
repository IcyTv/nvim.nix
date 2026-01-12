{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "svelte";
    description = "Enable Svelte support";
    filetypes = ["svelte"];
    lsp = {
      server = "svelte";
      package = pkgs.nodePackages.svelte-language-server;
    };
    format = {
      tool = "prettier-svelte";
      package = pkgs.nodePackages.prettier;
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for svelteserver. See https://github.com/sveltejs/language-tools/tree/master/packages/language-server#configuration for options.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--plugin=prettier-plugin-svelte" "--parser" "svelte"];
        description = "Additional arguments to pass to the prettier command for svelte.";
      };
    };

    extraConfig = cfg: {
      plugins.conform-nvim.settings.formatters."prettier-svelte".args = cfg.format.args;

      plugins.lsp.servers.svelte = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
