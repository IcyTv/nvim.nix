{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "python";
    description = "Enable Python support";
    lsp = {
      server = "basedpyright";
      package = pkgs.basedpyright;
    };
    format = {
      tool = "ruff";
      package = pkgs.ruff;
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          basedpyright.analysis.autoSearchPaths = true;
          basedpyright.analysis.useLibraryCodeForTypes = true;
          basedpyright.analysis.diagnosticMode = "openFilesOnly";
        };
        description = "Configuration for basedpyright.";
      };
    };

    extraConfig = cfg: {
      languages.toml.enable = lib.mkDefault true;

      plugins.lsp.servers.basedpyright = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
