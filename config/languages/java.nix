{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "java";
    filetypes = ["java"];
    description = "Enable Java support";
    lsp = {
      server = "jdtls";
      package = pkgs.jdt-language-server;
    };
    format = {
      tool = "google-java-format";
      package = pkgs.google-java-format;
    };
    lint = {
      tool = "checkstyle";
      package = pkgs.checkstyle;
    };
    extraConfig = cfg: {
      languages.gradle.enable = lib.mkDefault true;
    };
  } {
    inherit pkgs lib config;
  }
