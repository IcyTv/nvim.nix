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
      formatters_by_ft = {
        asm = ["asmfmt"];
        bash = ["shellcheck" "shellharden" "shfmt"];
        c = ["astyle"];
        cpp = ["astyle"];
        css = prettier;
        cmake = ["cmake_format"];
        html = prettier;
        javascript = prettier;
        javascriptreact = prettier;
        json = prettier;
        lua = ["stylua"];
        markdown = prettier;
        nix = ["alejandra"];
        python = ["isort" "black"];
        sh = ["shellcheck" "shellharden" "shfmt"];
        typescript = prettier;
        typescriptreact = prettier;
        yaml = prettier;
      };
      formatters = {
        asmfmt = {
          command = lib.getExe pkgs.asmfmt;
        };
        shellcheck = {
          command = lib.getExe pkgs.shellcheck;
        };
        shellharden = {
          command = lib.getExe pkgs.shellharden;
        };
        shfmt = {
          command = lib.getExe pkgs.shfmt;
        };
        astyle = {
          command = lib.getExe pkgs.astyle;
        };
        prettierd = {
          command = lib.getExe pkgs.prettierd;
        };
        prettier = {
          command = lib.getExe pkgs.prettier;
        };
        stylua = {
          command = lib.getExe pkgs.stylua;
        };
        alejandra = {
          command = lib.getExe pkgs.alejandra;
        };
        isort = {
          command = lib.getExe pkgs.isort;
        };
        black = {
          command = lib.getExe pkgs.black;
        };
      };
    };
  };

  plugins.guess-indent.enable = true;

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
