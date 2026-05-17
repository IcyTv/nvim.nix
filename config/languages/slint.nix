{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "slint";
    filetypes = ["slint"];
    description = "Enable Slint support";
    lsp = {
      server = "slint_lsp";
      package = pkgs.slint-lsp;
    };
  } {
    inherit pkgs lib config;
  }
