{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "rust";
    description = "Enable Rust support";
    lsp = {
      server = "rust_analyzer";
      package = pkgs.rust-analyzer;
    };
    format = {
      tool = "rustfmt";
      package = pkgs.rustfmt;
    };

    extraOptions = {
      toolchain = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Rust toolchain package (e.g. pkgs.rust-bin.stable.latest.default) to use for both LSP and formatting.";
      };
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          cargo.allFeatures = true;
          check.command = "clippy";
        };
        description = "Configuration for rust-analyzer. See https://rust-analyzer.github.io/manual.html#configuration for options.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
      installCargo = lib.mkEnableOption "Install cargo globally" // {default = false;};
      installRustc = lib.mkEnableOption "Install rustc globally" // {default = false;};
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the rustfmt command.";
      };
    };

    extraConfig = cfg: {
      languages.toml.enable = lib.mkDefault true;

      # Apply toolchain defaults if set
      languages.rust = lib.mkIf (cfg.toolchain != null) {
        lsp.package = lib.mkDefault cfg.toolchain;
        lsp.command = lib.mkDefault ["${cfg.toolchain}/bin/rust-analyzer"];
        format.package = lib.mkDefault cfg.toolchain;
        format.command = lib.mkDefault "${cfg.toolchain}/bin/rustfmt";
      };

      plugins.conform-nvim.settings.formatters."rustfmt".args = cfg.format.args;

      plugins.lsp.servers.rust_analyzer = {
        installCargo = cfg.lsp.installCargo;
        installRustc = cfg.lsp.installRustc;
        rustfmtPackage = lib.mkIf cfg.format.enable cfg.format.package;
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
