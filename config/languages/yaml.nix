{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "yaml";
    filetypes = ["yaml" "yaml.docker-compose"];
    description = "Enable YAML support";
    lsp = {
      server = "yamlls";
      package = pkgs.yaml-language-server;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };
    extraConfig = cfg: {
      plugins.schemastore = {
        enable = true;
        yaml.enable = true;
      };
    };
  } {
    inherit pkgs lib config;
  }
