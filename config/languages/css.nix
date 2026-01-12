{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "css";
    filetypes = ["css" "scss"];
    description = "Enable CSS support";
    lsp = {
      server = "cssls";
      package = pkgs.vscode-langservers-extracted;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };
  } {
    inherit pkgs lib config;
  }
