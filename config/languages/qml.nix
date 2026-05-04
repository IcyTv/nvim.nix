{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "qml";
    filetypes = ["qml"];
    description = "Enable QML support";
    lsp = {
      server = "qmlls";
      package = pkgs.qt6.qtdeclarative;
    };
    format = {
      tool = "qmlformat";
      package = pkgs.qt6.qtdeclarative;
    };
    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Command override for qmlls.";
      };
    };
    extraConfig = cfg: {
      plugins.lsp.servers.qmlls.cmd =
        if cfg.lsp.command != null
        then cfg.lsp.command
        else [
          (if cfg.lsp.package != null then lib.getExe cfg.lsp.package else "qmlls")
          "-E"
        ];
    };
  } {
    inherit pkgs lib config;
  }
