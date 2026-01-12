{
  pkgs,
  lib,
  ...
}: {
  plugins.lint = {
    enable = true;
    # lintersByFt and linters are now populated by language modules
  };

  extraConfigLua =
    # lua
    ''
      local lint = require("lint")
      local lint_autogroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_autogroup,
        callback = function()
          lint.try_lint()
        end,
      })
    '';

  keymaps = [
    {
      mode = ["n"];
      key = "<leader>cl";
      action = lib.nixvim.mkRaw ''function() require("lint").try_lint() end'';
      options.desc = "[c]ode [lint] the current buffer";
    }
  ];
}
