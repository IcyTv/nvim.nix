{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "zig";
    filetypes = ["zig"];
    description = "Enable Zig support";
    lsp = {
      server = "zls";
      package = pkgs.zls;
    };
    format = {
      tool = "zigfmt";
      package = pkgs.zig;
    };

    extraOptions = {
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Zig package to use for formatting (zig). Useful for matching the compiler version.";
      };
    };

    extraFormatOptions = {
      # Zig fmt is part of the zig binary
      command = lib.mkOption {
        type = lib.types.str;
        default = "${lib.getBin pkgs.zig}/bin/zig fmt";
        description = "Command to run formatter";
      };
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "ZLS settings";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };

    extraConfig = cfg: let
      # Best-effort version check (only works if 'version' attribute is present on the derivation)
      zigVersion = cfg.format.package.version or "unknown";
      zlsVersion = cfg.lsp.package.version or "unknown";
      # We compare only if both are known and differ. 
      # Note: This runs at eval time, so it checks the Nix derivation versions, 
      # which is exactly what we want to ensure the inputs match.
      versionMismatch = (zigVersion != "unknown") && (zlsVersion != "unknown") && (zigVersion != zlsVersion);
    in {
      warnings = lib.mkIf versionMismatch [
        "Zig version mismatch detected: Zig is ${zigVersion}, but ZLS is ${zlsVersion}. This may cause instability."
      ];

      # Apply toolchain defaults if set
      languages.zig = lib.mkIf (cfg.package != null) {
        format.package = lib.mkDefault cfg.package;
        format.command = lib.mkDefault "${lib.getBin cfg.package}/bin/zig fmt";
        
        # We can't strictly force LSP package because `zig` usually doesn't include `zls`.
        # But if the user passed a "toolchain" (often an environment containing both), we might want to try.
        # Let's leave LSP alone unless explicit.
      };

      # conform-nvim needs to know zig fmt modifies file in place or stdout? 
      # conform has a 'zigfmt' preset. It uses `zig fmt --stdin`.
      # We just need to point to the zig binary.
      plugins.conform-nvim.settings.formatters."zigfmt".command = 
        if cfg.format.package != null 
        then "${lib.getBin cfg.format.package}/bin/zig"
        else "zig";

      plugins.lsp.servers.zls = {
        cmd = cfg.lsp.command;
        extraOptions = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
