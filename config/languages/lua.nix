{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "lua";
    filetypes = ["lua"];
    description = "Enable Lua support";
    lsp = {
      server = "lua_ls";
      package = pkgs.lua-language-server;
    };
    format = {
      tool = "stylua";
      package = pkgs.stylua;
    };
    lint = {
      tool = "luacheck";
      package = pkgs.luajitPackages.luacheck;
    };
  } {
    inherit pkgs lib config;
  }
