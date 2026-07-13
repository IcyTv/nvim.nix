{...}: {
  plugins.lsp = {
    enable = true;
    keymaps = {
      diagnostic = {
        "<leader>cd" = "open_float";
      };

      extra = [
        {
          key = "<leader>j";
          action.__raw = ''
            function()
              vim.diagnostic.jump({ count = 1, float = true })
            end
          '';
          options.desc = "Jump to next diagnostic";
        }

        {
          key = "<leader>k";
          action.__raw = ''
            function()
              vim.diagnostic.jump({ count = -1, float = true })
            end
          '';
          options.desc = "Jump to previous diagnostic";
        }
      ];

      lspBuf = {
        "K" = "hover";
        "gD" = "references";
        "gd" = "definition";
        "gy" = "type_definition";
        "gi" = "implementation";
        "<leader>cr" = "rename";
        "<leader>ca" = "code_action";
      };
    };
  };

  plugins.lsp-lines.enable = true;
  plugins.lspkind.enable = true;
}
