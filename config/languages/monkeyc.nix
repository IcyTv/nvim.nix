{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};

  monkeycGrammar = pkgs.tree-sitter.buildGrammar {
    language = "monkeyc";
    version = "0.0.0-unstable-2026-07-19";
    src = pkgs.fetchFromGitHub {
      owner = "bombsimon";
      repo = "tree-sitter-monkey-c";
      rev = "6454acab6ff46cb6d1ae60b262caab0910c37a4a";
      hash = "sha256-g/UCcg96n/1HaLvFrlg88d0EaolCpjfxN6kmyCb9nVM=";
    };
  };
in
  utils.mkLang {
    name = "monkeyc";
    filetypes = ["monkeyc"];
    description = "Enable Monkey C support";

    extraConfig = cfg: {
      plugins.treesitter.grammarPackages = [monkeycGrammar];
    };
  } {
    inherit pkgs lib config;
  }
