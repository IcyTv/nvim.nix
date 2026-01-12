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
    extraFormatOptions = {
      # Override command because getExe pkgs.clang-tools defaults to clangd
      command = lib.mkOption {
        type = lib.types.str;
        default = "${lib.getBin pkgs.clang-tools}/bin/clang-format";
        description = "Command to run formatter";
      };
    };
  } {
    inherit pkgs lib config;
  }
