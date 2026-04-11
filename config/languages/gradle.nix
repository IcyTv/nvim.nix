{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "gradle";
    filetypes = ["groovy" "kotlin"];
    description = "Enable Gradle support";
    lsp = {
      server = "gradle_ls";
      package = null;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command to start gradle_ls. Set when providing your own gradle language server.";
      };
    };

    extraConfig = cfg: {
      extraPackages = [pkgs.gradle];

      plugins.lsp.servers.gradle_ls = lib.mkIf cfg.lsp.enable {
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
