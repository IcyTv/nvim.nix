{lib, ...}: {
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
      sections = {
        lualine_z = lib.nixvim.mkRaw ''          {
                    require("opencode").statusline
                  }'';
      };
    };
  };
  plugins.bufferline.enable = true;

  plugins.dashboard = {
    enable = true;
    settings = {
      change_vcs_root = true;
      config = {
        project.enable = false;
        mru = {
          enable = true;
          limit = 10;
          cwd_only = true;
        };
        packages.enable = true;
        week_header.enable = true;

        shortcut = [
          {
            action = lib.nixvim.mkRaw ''function() vim.cmd('Telescope find_files') end'';
            desc = "Files";
            group = "Label";
            icon = " ";
            icon_hl = "@variable";
            key = "f";
          }
          {
            action = "Telescope zoxide list";
            desc = " Folders";
            group = "DiagnosticHint";
            key = "z";
          }
          {
            # TODO read from cwd on build or something. Idk...
            action = "Telescope find_files cwd=~/projects/nvim.nix";
            desc = "󰊢 Neovim Config Files";
            group = "DiagnosticHint";
            key = "c";
          }
          {
            action = "Telescope find_files cwd=~/.dotfiles/nix";
            desc = " dotfiles";
            group = "Number";
            key = "d";
          }
        ];
      };
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
