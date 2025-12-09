{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.tailwind;
in {
  options.languages.tailwind = {
    enable = lib.mkEnableOption "Enable Tailwind CSS support";
    lsp = {
      enable = lib.mkEnableOption "Enable LSP for Tailwind CSS" // {default = true;};
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Configuration for tailwindcss-language-server. See https://github.com/tailwindlabs/tailwindcss-intellisense/blob/master/packages/tailwindcss-language-server/README.md#settings for options.";
      };
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.tailwindcss-language-server;
        description = "The tailwindcss-language-server package to use";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };
    format = {
      enable = lib.mkEnableOption "Enable formatting for Tailwind CSS" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.nodePackages.prettier;
      };
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--plugin=prettier-plugin-tailwindcss"];
        description = "Additional arguments to pass to the prettier command for tailwind.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        tailwind = ["prettier-tailwind"];
      };
      formatters = {
        "prettier-tailwind" = {
          command = lib.getExe cfg.format.package;
          args = cfg.format.args;
        };
      };
    };
    plugins.lsp.servers.tailwindcss = lib.mkIf cfg.lsp.enable {
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
