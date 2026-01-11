{
  pkgs,
  lib,
  ...
}: {
  plugins.lint = {
    enable = true;
    lintersByFt = {
      c = ["clangtidy"];
      cpp = ["clangtidy"];
      css = ["eslint_d"];
      gitcommit = ["gitlint"];
      javascript = ["eslint_d"];
      javascriptreact = ["eslint_d"];
      json = ["jsonlint"];
      lua = ["luacheck"];
      markdown = ["markdownlint"];
      nix = ["nix"];
      python = ["ruff"];
      sh = ["shellcheck"];
      typescript = ["eslint_d"];
      typescriptreact = ["eslint_d"];
      yaml = ["yamllint"];
    };
    linters = {
      clangtidy.cmd = "${pkgs.clang-tools}/bin/clang-tidy";
      eslint_d.cmd = lib.getExe pkgs.eslint_d;
      gitlint.cmd = lib.getExe pkgs.gitlint;
      jsonlint.cmd = "${pkgs.python313Packages.demjson3}/bin/jsonlint";
      luacheck.cmd = lib.getExe pkgs.luajitPackages.luacheck;
      markdownlint.cmd = lib.getExe pkgs.markdownlint-cli2;
      nix.cmd = lib.getExe pkgs.nix;
      ruff.cmd = lib.getExe pkgs.ruff;
      shellcheck.cmd = lib.getExe pkgs.shellcheck;
      yamllint.cmd = lib.getExe pkgs.yamllint;
    };
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
