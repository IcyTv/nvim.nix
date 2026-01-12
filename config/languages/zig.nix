{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "zig";
    filetypes = ["zig"];
    description = "Enable Zig support";
    lsp = {
      server = "zls";
      package = pkgs.zls;
    };
    format = {
      tool = "zigfmt";
      package = pkgs.zig;
    };
    extraFormatOptions = {
      # Zig fmt is part of the zig binary
      command = lib.mkOption {
        type = lib.types.str;
        default = "${lib.getBin pkgs.zig}/bin/zig fmt";
        description = "Command to run formatter";
      };
    };
    extraConfig = cfg: {
      # conform-nvim needs to know zig fmt modifies file in place or stdout? 
      # conform has a 'zigfmt' preset. It uses `zig fmt --stdin`.
      # We just need to point to the zig binary.
      plugins.conform-nvim.settings.formatters."zigfmt".command = "${lib.getBin pkgs.zig}/bin/zig";
    };
  } {
    inherit pkgs lib config;
  }
