{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.shell;
in {
  options.languages.shell = {
    enable = lib.mkEnableOption "Enable shell (sh/bash) support";
    lsp.enable = lib.mkEnableOption "Enable LSP support for shell" // {default = true;};
    format = {
      enable = lib.mkEnableOption "Enable all shell formatting" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.shfmt;
        description = "Package to use for formatting";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        sh = ["shfmt"];
        bash = ["shfmt"];
      };
      formatters = {
        shfmt.command = lib.getExe cfg.format.package;
      };
    };

    extraPackages = lib.mkIf cfg.lsp.enable [pkgs.bash-language-server];
    plugins.lsp.servers.bashls.enable = cfg.lsp.enable;
  };
}
