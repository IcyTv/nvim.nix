{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "c";
    filetypes = ["c" "cpp" "objc" "objcpp"];
    description = "Enable C/C++ support";
    lsp = {
      server = "clangd";
      package = pkgs.clang-tools;
    };
    format = {
      tool = "clang-format";
      package = pkgs.clang-tools;
    };

    extraLspOptions = {
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = [
          "clangd"
          "--background-index"
          "--clang-tidy"
          "--header-insertion=iwyu"
          "--completion-style=detailed"
          "--function-arg-placeholders"
          "--fallback-style=llvm"
        ];
        description = "Command to start clangd. Defaults to enabling background indexing, clang-tidy, and detailed completion.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
        description = "Extra configuration for clangd (usually passed via extraOptions).";
      };
    };

    extraFormatOptions = {
      # Override command because getExe pkgs.clang-tools defaults to clangd
      command = lib.mkOption {
        type = lib.types.str;
        default = "${lib.getBin pkgs.clang-tools}/bin/clang-format";
        description = "Command to run formatter";
      };
    };

    extraConfig = cfg: {
      plugins.lsp.servers.clangd = {
        cmd = cfg.lsp.command;
        extraOptions = cfg.lsp.settings;
      };
    };
  } {
    inherit pkgs lib config;
  }
