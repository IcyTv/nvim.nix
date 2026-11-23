{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "flutter";
    description = "Enable Flutter support (via flutter-tools.nvim)";

    extraOptions = {
      package = lib.mkOption {
        type = with lib.types; nullOr package;
        default = pkgs.flutter;
        description = "Flutter SDK package to use. Set to null to use the one in your PATH.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Settings passed to flutter-tools.nvim. See https://github.com/akinsho/flutter-tools.nvim#setup for options.";
      };
    };

    extraConfig = cfg: {
      # flutter-tools.nvim starts and manages its own Dart analysis server;
      # also enabling languages.dart's dartls would attach a second LSP
      # client to the same Dart buffers.
      languages.dart.enable = lib.mkDefault true;
      languages.dart.lsp.enable = lib.mkDefault false;

      extraPackages = lib.optional (cfg.package != null) cfg.package;

      plugins.flutter-tools = {
        enable = true;
        settings = cfg.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
