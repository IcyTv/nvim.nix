{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./ai.nix
    ./treesitter.nix
    ./telescope.nix
    ./completion.nix
    ./default-keymaps.nix
    ./folds.nix
    ./format.nix
    ./lint.nix
    ./style.nix
    ./lsp.nix
  ];

  config = {
    globals = {
      mapleader = " ";
    };

    # Disable the version check to allow consuming this flake with different nixpkgs versions
    version.enableNixpkgsReleaseCheck = false;

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 4;
      shiftwidth = 4;
      expandtab = false;
      wrap = false;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      foldlevel = 99;
    };

    editorconfig.enable = true;

    plugins = {
      gitsigns.enable = true;
      undotree.enable = true;
      fugitive.enable = true;
      nvim-tree.enable = true;
    };
    plugins.image = {
      enable = true;
      settings = {
        backend = "kitty";
      };
    };

    extraPackages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
