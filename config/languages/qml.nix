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
  } {
    inherit pkgs lib config;
  }
