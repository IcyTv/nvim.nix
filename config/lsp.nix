{...}: {
  plugins.lsp = {
    enable = true;
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cmake.enable = true;
      cssls.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      nixd.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      ts_ls.enable = true;
      yamlls.enable = true;
    };
    keymaps = {
      diagnostic = {
        "<leader>j" = "goto_next";
        "<leader>k" = "goto_prev";
      };

      lspBuf = {
        "K" = "hover";
        "gD" = "references";
        "gd" = "definition";
        "gy" = "type_definition";
        "gi" = "implementation";
        "<leader>cr" = "rename";
      };
    };
  };

  plugins.lsp-lines.enable = true;
  plugins.lspkind.enable = true;
}
