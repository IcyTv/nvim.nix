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
    filetypes = ["qml" "qmljs"];
    description = "Enable QML support";
    lsp = {
      server = "qmlls";
      package = pkgs.qt6.qtdeclarative;
      packageName = "qmlls";
    };
    format = {
      tool = "qmlformat";
      package = pkgs.qt6.qtdeclarative;
    };
    extraLspOptions = {
      packageName = lib.mkOption {
        type = lib.types.str;
        default = lsp.packageName or lsp.server;
        description = "Executable name inside lsp.package to use.";
      };
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
          (if cfg.lsp.package != null then "${cfg.lsp.package}/bin/${cfg.lsp.packageName}" else "qmlls")
          "-E"
        ];
    };
  } {
    inherit pkgs lib config;
  }
