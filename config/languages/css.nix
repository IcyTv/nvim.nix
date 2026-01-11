{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.shell;
in {
  options.languages.css = {
    enable = lib.mkEnableOption "Enable CSS support";
    lsp.enable = lib.mkEnableOption "Enable LSP support for css" // {default = true;};
    format = {
      enable = lib.mkEnableOption "Enable all css formatting" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.prettierd;
        description = "Package to use for formatting";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        css = ["prettierd"];
        scss = ["prettierd"];
      };
      formatters = {
        prettierd.command = lib.getExe cfg.format.package;
      };
    };

    plugins.lsp.servers.cssls.enable = cfg.lsp.enable;
  };
}
