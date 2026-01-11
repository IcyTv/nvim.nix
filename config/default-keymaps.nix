{lib, ...}: let
  mapSilent = desc: {
    desc = desc;
    silent = true;
  };
in {
  plugins.snacks.enable = true;

  keymaps = [
    # Better up/down from LazyVim
    {
      mode = ["n" "x"];
      key = "j";
      action = ''v:count == 0 ? "gj" : "j"'';
      options = {
        desc = "Down";
        expr = true;
        silent = true;
      };
    }
    {
      mode = ["n" "x"];
      key = "<Down>";
      action = ''v:count == 0 ? "gj" : "j"'';
      options = {
        desc = "Down";
        expr = true;
        silent = true;
      };
    }
    {
      mode = ["n" "x"];
      key = "k";
      action = ''v:count == 0 ? "gk" : "k"'';
      options = {
        desc = "Up";
        expr = true;
        silent = true;
      };
    }
    {
      mode = ["n" "x"];
      key = "<Up>";
      action = ''v:count == 0 ? "gk" : "k"'';
      options = {
        desc = "Down";
        expr = true;
        silent = true;
      };
    }

    # Move to window using <ctrl> hjkl
    {
      mode = ["n"];
      key = "<C-h>";
      action = "<C-w>h";
      options = mapSilent "Move to left window";
    }
    {
      mode = ["n"];
      key = "<C-j>";
      action = "<C-w>j";
      options = mapSilent "Move to lower window";
    }
    {
      mode = ["n"];
      key = "<C-k>";
      action = "<C-w>k";
      options = mapSilent "Move to upper window";
    }
    {
      mode = ["n"];
      key = "<C-l>";
      action = "<C-w>l";
      options = mapSilent "Move to right window";
    }

    # Resize windows using <ctrl> arrow keys
    {
      mode = ["n"];
      key = "<C-Up>";
      action = ":resize +2<CR>";
      options = mapSilent "Increase Window height";
    }
    {
      mode = ["n"];
      key = "<C-Down>";
      action = ":resize -2<CR>";
      options = mapSilent "Decrease Window height";
    }
    {
      mode = ["n"];
      key = "<C-Left>";
      action = ":vertical resize -2<CR>";
      options = mapSilent "Decrease Window width";
    }
    {
      mode = ["n"];
      key = "<C-Right>";
      action = ":vertical resize +2<CR>";
      options = mapSilent "Increase Window width";
    }

    # Move lines
    {
      mode = ["n"];
      key = "<A-j>";
      action = ":m .+1<CR>==";
      options = mapSilent "Move down line";
    }
    {
      mode = ["n"];
      key = "<A-k>";
      action = ":m .-2<CR>==";
      options = mapSilent "Move up line";
    }
    {
      mode = ["v"];
      key = "<A-j>";
      action = ":m '>+1<CR>gv=gv";
      options = mapSilent "Move down line";
    }
    {
      mode = ["v"];
      key = "<A-k>";
      action = ":m '<-2<CR>gv=gv";
      options = mapSilent "Move up line";
    }
    {
      mode = ["i"];
      key = "<A-j>";
      action = "<Esc>:m .+1<CR>==gi";
      options = mapSilent "Move down line";
    }
    {
      mode = ["i"];
      key = "<A-k>";
      action = "<Esc>:m .-2<CR>==gi";
      options = mapSilent "Move up line";
    }

    # Buffers
    {
      mode = ["n"];
      key = "<S-h>";
      action = ":bprevious<CR>";
      options = mapSilent "Previous buffer";
    }
    {
      mode = ["n"];
      key = "<S-l>";
      action = ":bnext<CR>";
      options = mapSilent "Next buffer";
    }
    {
      mode = ["n"];
      key = "[b";
      action = ":bprevious<CR>";
      options = mapSilent "Previous buffer";
    }
    {
      mode = ["n"];
      key = "]b";
      action = ":bnext<CR>";
      options = mapSilent "Next buffer";
    }
    {
      mode = ["n"];
      key = "<leader>bb";
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      mode = ["n"];
      key = "<leader>`";
      action = "<cmd>e #<cr>";
      options.desc = "Switch to Other Buffer";
    }
    {
      mode = ["n"];
      key = "<leader>bd";
      action = lib.nixvim.mkRaw ''function() require("snacks").bufdelete() end'';
      options.desc = "Delete current buffer";
    }
    {
      mode = ["n"];
      key = "<leader>bo";
      action = lib.nixvim.mkRaw ''function() require("snacks").bufdelete.other() end'';
      options.desc = "Delete other buffers";
    }
    {
      mode = ["n"];
      key = "<leader>bD";
      action = "<cmd>:bd<cr>";
      options.desc = "Delete Buffer and Window";
    }

    # Clear search and stop snippet on escape
    {
      mode = ["n" "i" "s"];
      key = "<esc>";
      action = lib.nixvim.mkRaw ''        function()
          vim.cmd("noh")
          require("cmp").actions.snippet_stop()
          return "<esc>"
        end'';
      options = {
        expr = true;
        desc = "Clear search highlighting";
      };
    }

    # Better indenting
    {
      mode = ["x"];
      key = "<";
      action = "<gv";
      options = mapSilent "Indent left";
    }
    {
      mode = ["x"];
      key = ">";
      action = ">gv";
      options = mapSilent "Indent right";
    }

    # Windows
    {
      mode = ["n"];
      key = "<leader>-";
      action = "<C-W>s";
      options = {
        desc = "Split window horizontally";
        remap = true;
      };
    }
    {
      mode = ["n"];
      key = "<leader>|";
      action = "<C-W>v";
      options = {
        desc = "Split window vertically";
        remap = true;
      };
    }
    {
      mode = ["n"];
      key = "<leader>wd";
      action = "<C-W>c";
      options = {
        desc = "Close current window";
        remap = true;
      };
    }
    {
      mode = ["n"];
      key = "<leader>wm";
      action = lib.nixvim.mkRaw ''        function()
                Snacks.toggle.zoom()
              end'';
      options.desc = "Maximize window";
    }
    {
      mode = ["n"];
      key = "<leader>wZ";
      action = lib.nixvim.mkRaw ''        function()
                Snacks.toggle.zen()
              end'';
      options.desc = "Zen mode";
    }

    # Tabs
    {
      mode = ["n"];
      key = "<leader>tj";
      action = "<cmd>tablast<CR>";
      options = mapSilent "Last tab";
    }
    {
      mode = ["n"];
      key = "<leader>tk";
      action = "<cmd>tabfirst<CR>";
      options = mapSilent "First tab";
    }
    {
      mode = ["n"];
      key = "<leader>to";
      action = "<cmd>tabonly<CR>";
      options = mapSilent "Close other tabs";
    }
    {
      mode = ["n"];
      key = "<leader>tn";
      action = "<cmd>tabnew<CR>";
      options = mapSilent "New tab";
    }
    {
      mode = ["n"];
      key = "<leader>tt";
      action = "<cmd>tabnew<CR>";
      options = mapSilent "New tab";
    }
    {
      mode = ["n"];
      key = "<leader>th";
      action = "<cmd>tabprevious<CR>";
      options = mapSilent "Previous tab";
    }
    {
      mode = ["n"];
      key = "<leader>tl";
      action = "<cmd>tabnext<CR>";
      options = mapSilent "Next tab";
    }
    {
      mode = ["n"];
      key = "<leader>td";
      action = "<cmd>tabclose<CR>";
      options = mapSilent "Close tab";
    }
  ];
}
