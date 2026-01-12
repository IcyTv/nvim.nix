{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "nix";
    filetypes = ["nix"];
    description = "Enable Nix support";
    lsp = {
      server = "nixd";
      package = pkgs.nixd;
    };
    format = {
      tool = "alejandra";
      package = pkgs.alejandra;
    };
  } {
    inherit pkgs lib config;
  }
