{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.nix;
in {
  options.languages.nix = {
    enable = lib.mkEnableOption "Enable nix support";
    lsp.enable = lib.mkEnableOption "Enable LSP for nix" // {default = true;};
    format = {
      enable = lib.mkEnableOption "Enable formatting for Nix" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.alejandra;
        description = "Package to use for the nix formatter. Default: alejandra";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPackages = [pkgs.alejandra];
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        nix = ["alejandra"];
      };
      formatters = {
        "alejandra".command = lib.getExe cfg.format.package;
      };
    };

    plugins.lsp.servers.nixd.enable = cfg.lsp.enable;
  };
}
