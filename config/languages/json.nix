{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "json";
    filetypes = ["json" "jsonc"];
    description = "Enable JSON support";
    lsp = {
      server = "jsonls";
      package = pkgs.vscode-langservers-extracted;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };
    lint = {
      tool = "jsonlint";
      package = pkgs.python313Packages.demjson3;
    };
  } {
    inherit pkgs lib config;
  }
