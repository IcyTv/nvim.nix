{
  pkgs,
  lib,
  ...
}: let
  cfg = lib.options.languages.rust;
in {
  options.languages.rust = {
    enable = lib.mkEnableOption "Enable Rust support";
    lsp.enable = lib.mkEnableOption "Enable LSP for Rust";
    format = {
      enable = lib.mkEnableOption "Enable formatting for Rust";
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.rustfmt;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    extraPackages = [pkgs.rust-analyzer];
    programs.nixvim = {
      lsp.rust-analyzer = lib.mkIf cfg.lsp.enable {};
      format."rustfmt" = lib.mkIf cfg.format.enable {
        enable = true;
        package = cfg.format.package;
      };
    };
  };
}
