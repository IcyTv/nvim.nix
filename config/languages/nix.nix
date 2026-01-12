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
    # For nix, we want to enable both deadnix and statix, but mkLang only supports one simple linter arg for now.
    # We will use extraConfig to add the second one, and pass one of them as the primary.
    lint = {
      tool = "deadnix";
      package = pkgs.deadnix;
    };

    extraConfig = cfg: {
       # Add statix as a secondary linter
       plugins.lint.lintersByFt.nix = ["statix"]; # Note: this merges/appends if we use mkMerge, but mkLang uses mkMerge.
       # Wait, if I set lintersByFt.nix in mkLang to [lint.tool], and here I set it to ["statix"], 
       # since they are in a mkMerge list, they might conflict or merge.
       # nixvim lists merge by appending. So we should get ["deadnix" "statix"].
       
       plugins.lint.linters.statix = {
         cmd = lib.getExe pkgs.statix;
       };
    };
  } {
    inherit pkgs lib config;
  }
