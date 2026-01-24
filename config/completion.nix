{...}: {
  plugins.cmp = {
    enable = true;
    settings = {
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-b>" = "cmp.mapping.scroll_docs(-4)";
        "<C-f>" = "cmp.mapping.scroll_docs(4)";
        "<C-n>" = "cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.None })";
        "<C-p>" = "cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.None })";
        "<CR>" = "cmp.mapping.confirm()";
        "<C-y>" = "cmp.mapping.confirm()";
      };
      performance = {
        async_budget = 1;
        debounce = 60;
        throttle = 30;
        fetchingTimeout = 200;
      };
      sources = [
        {name = "copilot";}
        {name = "nvim_lua";}
        {name = "nvim_lsp";}
        {name = "async_path";}
        {name = "luasnip";}
        {name = "treesitter";}
        {name = "buffer";}
        {name = "spell";}
      ];
      window.documentation.border = [
        "╭"
        "─"
        "╮"
        "│"
        "╯"
        "─"
        "╰"
        "│"
      ];
    };
  };

  plugins.copilot-cmp.enable = true;
  plugins.cmp-buffer.enable = true;
  plugins.cmp-nvim-lsp.enable = true;
  plugins.cmp-nvim-lua.enable = true;
  plugins.cmp-async-path.enable = true;
  plugins.luasnip.enable = true;
  plugins.cmp-spell.enable = true;
}
