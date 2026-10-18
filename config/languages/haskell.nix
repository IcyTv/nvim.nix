{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "haskell";
    filetypes = ["haskell"];
    description = "Enable Haskell support";
    lsp = {
      server = "hls";
      package = pkgs.haskell-language-server;
    };
    format = {
      tool = "fourmolu";
      package = pkgs.fourmolu;
    };
    lint = {
      tool = "hlint";
      package = pkgs.hlint;
    };

    extraOptions = {
      cabalFormat = {
        enable = lib.mkEnableOption "Enable Cabal file formatting with cabal-fmt" // {default = true;};
        package = lib.mkOption {
          type = with lib.types; nullOr package;
          default = pkgs.haskellPackages.cabal-fmt;
          description = "cabal-fmt package to use. Set to null to use the one in your PATH.";
        };
        command = lib.mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Command to run cabal formatter. Defaults to cabalFormat.package executable or 'cabal-fmt'.";
        };
      };
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start the Haskell language server. Defaults to ['haskell-language-server-wrapper' '--lsp'].";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          haskell = {
            formattingProvider = "fourmolu";
            cabalFormattingProvider = "cabal-fmt";
          };
        };
        description = "Configuration for haskell-language-server. See HLS documentation for available options.";
      };
      installGhc = lib.mkEnableOption "Install GHC globally via Nixvim" // {default = false;};
      ghcPackage = lib.mkOption {
        type = with lib.types; nullOr package;
        default = pkgs.ghc;
        description = "GHC package to install when installGhc is enabled.";
      };
      filetypes = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Filetypes to attach HLS to. Defaults to HLS default (['haskell' 'lhaskell']).";
      };
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the fourmolu command.";
      };
    };

    extraLintOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the hlint command.";
      };
    };

    extraConfig = cfg: let
      cabalCommand =
        if cfg.cabalFormat.command != null
        then cfg.cabalFormat.command
        else if cfg.cabalFormat.package != null
        then lib.getExe cfg.cabalFormat.package
        else "cabal-fmt";
    in {
      languages.yaml.enable = lib.mkDefault true;

      plugins.lsp.servers.hls = lib.mkIf cfg.lsp.enable {
        installGhc = cfg.lsp.installGhc;
        ghcPackage = lib.mkIf (cfg.lsp.ghcPackage != null) cfg.lsp.ghcPackage;
        cmd = cfg.lsp.command;
        extraOptions = cfg.lsp.settings;
        filetypes = lib.mkIf (cfg.lsp.filetypes != null) cfg.lsp.filetypes;
      };

      plugins.conform-nvim.settings = lib.mkMerge [
        (lib.mkIf (cfg.format.enable && cfg.format.args != []) {
          formatters.fourmolu.append_args = cfg.format.args;
        })
        (lib.mkIf (cfg.format.enable && cfg.cabalFormat.enable) {
          formatters_by_ft.cabal = ["cabal_fmt"];
          formatters.cabal_fmt.command = cabalCommand;
        })
      ];

      plugins.lint = lib.mkIf cfg.lint.enable {
        lintersByFt.lhaskell = ["hlint"];
        linters.hlint = lib.mkIf (cfg.lint.args != []) {
          args = ["--json" "--no-exit-code"] ++ cfg.lint.args;
        };
      };
    };
  } {
    inherit pkgs lib config;
  }
