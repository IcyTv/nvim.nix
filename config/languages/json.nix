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
  } {
    inherit pkgs lib config;
  }
