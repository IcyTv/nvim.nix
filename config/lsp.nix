{...}: {
  plugins.lsp = {
    enable = true;
    keymaps = {
      diagnostic = {
        "<leader>j" = "goto_next";
        "<leader>k" = "goto_prev";
        "<leader>cd" = "open_float";
      };

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
