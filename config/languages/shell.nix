{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "shell";
    filetypes = ["sh" "bash"];
    description = "Enable shell (sh/bash) support";
    lsp = {
      server = "bashls";
      package = pkgs.bash-language-server;
    };
    format = {
      tool = "shfmt";
      package = pkgs.shfmt;
    };
  } {
    inherit pkgs lib config;
  }
