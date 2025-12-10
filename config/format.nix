{
  pkgs,
  lib,
  ...
}: let
  prettier = ["prettierd" "prettier" {stop_after_first = true;}];
in {
  plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts = {
        lsp_format = "first";
      };
      format_on_save = {
        lsp_fallback = true;
        timeout_ms = 500;
      };
    };
  };

  # plugins.guess-indent.enable = true;
  plugins.sleuth.enable = true;

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>cf";
      action = ":lua _G.format_with_conform()<CR>";
      options.desc = "Format file or range (in visual mode)";
    }
  ];

  extraConfigLuaPre =
    #lua
    ''
      _G.format_with_conform = function()
        require("conform").format({ async = true, timeout_ms = 500, lsp_fallback = true })
      end
    '';
}
