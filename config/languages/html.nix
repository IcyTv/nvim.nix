{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "html";
    filetypes = ["html"];
    description = "Enable HTML support";
    lsp = {
      server = "html";
      package = pkgs.vscode-langservers-extracted;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };
  } {
    inherit pkgs lib config;
  }
