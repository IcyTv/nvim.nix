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
        # mkLang will automatically update format.command to match the new package
        
        # We can't strictly force LSP package because `zig` usually doesn't include `zls`.
      };

      plugins.lsp.servers.zls = {
        cmd = cfg.lsp.command;
        extraOptions = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
