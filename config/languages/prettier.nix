{
  pkgs,
  lib,
  config,
  ...
}: let
  # Define the default configuration content
  defaultConfigContent = {
    useTabs = true;
    tabWidth = 4;
    arrowParens = "always";
    printWidth = 180;
    singleQuote = true;
    semi = true;
  };

  # Write the config to a file in the Nix store
  defaultConfigFile = pkgs.writeText ".prettierrc.json" (builtins.toJSON defaultConfigContent);
in {
  # Define the centralized prettierd configuration
  plugins.conform-nvim.settings.formatters.prettierd = {
    # Point PRETTIERD_DEFAULT_CONFIG to our generated file
    env = {
      PRETTIERD_DEFAULT_CONFIG = "${defaultConfigFile}";
    };
  };

  # Ensure prettierd is available
  extraPackages = [pkgs.prettierd];
}
