{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "toml";
    filetypes = ["toml"];
    description = "Enable TOML support";
    lsp = {
      server = "taplo";
      package = pkgs.taplo;
    };
    format = {
      tool = "taplo";
      package = pkgs.taplo;
    };
  } {
    inherit pkgs lib config;
  }
