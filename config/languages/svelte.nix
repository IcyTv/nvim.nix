{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.svelte;
in {
  options.languages.svelte = {
    enable = lib.mkEnableOption "Enable Svelte support";
    lsp = {
      enable = lib.mkEnableOption "Enable LSP for Svelte" // {default = true;};
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for svelteserver. See https://github.com/sveltejs/language-tools/tree/master/packages/language-server#configuration for options.";
      };
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.nodePackages.svelte-language-server;
        description = "The svelte-language-server package to use";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };
    format = {
      enable = lib.mkEnableOption "Enable formatting for Svelte" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.nodePackages.prettier;
      };
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--plugin=prettier-plugin-svelte" "--parser" "svelte"];
        description = "Additional arguments to pass to the prettier command for svelte.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        svelte = ["prettier-svelte"];
      };
      formatters = {
        "prettier-svelte" = {
          command = lib.getExe cfg.format.package;
          args = cfg.format.args;
        };
      };
    };
    plugins.lsp.servers.svelte = lib.mkIf cfg.lsp.enable {
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
