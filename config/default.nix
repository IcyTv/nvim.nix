{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./treesitter.nix
    ./telescope.nix
    ./completion.nix
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

    opts = {
      number = true;
      relativenumber = true;
      tabstop = 4;
      wrap = false;
      hlsearch = false;
      incsearch = true;
      termguicolors = true;
      scrolloff = 8;
      signcolumn = "yes";
      updatetime = 50;
      foldlevel = 99;
    };

    plugins = {
      gitsigns.enable = true;
      undotree.enable = true;
      fugitive.enable = true;
      nvim-tree.enable = true;
    };

    extraPackages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
