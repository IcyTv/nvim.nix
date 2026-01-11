{pkgs, ...}: {
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      integrations = {
        gitsigns = true;
        nvimtree = true;
        treesitter = true;
        notify = true;
        lualine = true;
        dashboard = true;
        mini.enable = true;
      };
    };
  };

  plugins.notify.enable = true;
  plugins.noice = {
    enable = true;
    settings.presets.bottom_search = true;
  };
  plugins.lualine = {
    enable = true;
    settings = {
      iconsEnabled = true;
      globalstatus = true;
    };
  };
  plugins.bufferline.enable = true;

  plugins.dashboard = {
    enable = true;
    settings = {
      project.enable = true;
    };
  };

  plugins.mini = {
    enable = true;
    mockDevIcons = true;

    modules = {
      ai = {};
      align = {};
      comment = {};
      move = {};
      pairs = {};
      splitjoin = {};
      surround = {};
      basics = {};
      bracketed = {};
      bufremove = {};
      diff = {};
      jump = {};
      jump2d = {};
      pick = {};
      sessions = {};
      icons = {};
    };
  };

  plugins.which-key.enable = true;

  plugins.nvim-tree = {
    enable = true;
  };

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>e";
      action = "<cmd>NvimTreeToggle<CR>";
      options.desc = "[ ] Open file [e]xplorer";
      options.silent = true;
    }
  ];
}
