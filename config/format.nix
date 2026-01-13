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

  # Force vim-sleuth to default to tabstop=4 (instead of 8) when it detects hard tabs
  # but cannot determine the width from neighbors.
  autoCmd = [
    {
      event = ["BufReadPre" "BufNewFile"];
      command = "let b:sleuth_defaults = 'tabstop=4'";
    }
    {
      # Run Sleuth after saving to re-adjust indentation based on the new file content
      # (e.g. after a formatter changes indentation styles)
      event = ["BufWritePost"];
      command = "Sleuth";
    }
  ];

  # Explicitly enable automatic detection (default is 1, but setting for clarity)
  globals.sleuth_automatic = 1;

  userCommands = {
    W = {
      command = "noautocmd w<bang>";
      bang = true;
      desc = "Write without formatting";
    };
    Wq = {
      command = "noautocmd wq<bang>";
      bang = true;
      desc = "Write and quit without formatting";
    };
    Wqa = {
      command = "noautocmd wqa<bang>";
      bang = true;
      desc = "Write all and quit without formatting";
    };
  };

  keymaps = [
    {
      mode = ["n" "v"];
      key = "<leader>cf";
      action = lib.nixvim.mkRaw "function() _G.format_with_conform() end";
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
