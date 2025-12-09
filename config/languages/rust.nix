{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.languages.rust;
in {
  options.languages.rust = {
    enable = lib.mkEnableOption "Enable Rust support";
    lsp = {
      enable = lib.mkEnableOption "Enable LSP for Rust" // {default = true;};
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          cargo.allFeatures = true;
          checkOnSave.command = "clippy";
        };
        description = "Configuration for rust-analyzer. See https://rust-analyzer.github.io/manual.html#configuration for options.";
      };
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.rust-analyzer;
        description = "The rust-analyzer package to use";
      };
      command = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["${cfg.lsp.package}/bin/rust-analyzer"];
      };
    };
    format = {
      enable = lib.mkEnableOption "Enable formatting for Rust" // {default = true;};
      package = lib.mkOption {
        type = with lib.types; package;
        default = pkgs.rustfmt;
      };
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the rustfmt command.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # programs.nixvim = {
    #   lsp.rust-analyzer = lib.mkIf cfg.lsp.enable {};
    #   format."rustfmt" = lib.mkIf cfg.format.enable {
    #     enable = true;
    #     package = cfg.format.package;
    #   };
    # };
    assertions = {
      assertion = !(cfg.lsp.package != null && cfg.lsp.cmd != null);
      message = "The options `language.rust.lsp.package` and `language.rust.lsp.command` are mutually exclusive. Using command will override the package anyways.";
    };
    plugins.conform-nvim.settings = lib.mkIf cfg.format.enable {
      formatters_by_ft = {
        rust = ["rustfmt"];
      };
      formatters = {
        "rustfmt" = {
          command = lib.getExe cfg.format.package;
          args = cfg.format.args;
        };
      };
    };
    plugins.lsp.servers.rust_analyzer = lib.mkIf cfg.lsp.enable {
      enable = true;
      installCargo = true;
      installRustc = true;
      rustfmtPackage = lib.mkIf cfg.format.enable cfg.format.package;

      extraOptions = cfg.lsp.settings;
      # package = lib.mkIf (cfg.lsp.command == null) cfg.lsp.
      package =
        if cfg.lsp.command == null
        then cfg.lsp.package
        else lib.mkForce null;
      cmd = cfg.lsp.command;
    };
  };
}
