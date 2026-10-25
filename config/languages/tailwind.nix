{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "tailwind";
    description = "Enable Tailwind CSS support";
    filetypes = ["tailwind"]; # Keep prettierd scoped to the tailwind filetype.
    lsp = {
      server = "tailwindcss";
      package = pkgs.tailwindcss-language-server;
    };
    format = {
      tool = "prettierd";
      package = pkgs.prettierd;
    };

    extraLspOptions = {
      filetypes = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
        description = "Filetypes to attach Tailwind CSS to. Null enables all filetypes; an empty list disables attachment.";
      };
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          "files.exclude" = [
            "**/.git/**"
            "**/.svn/**"
            "**/.hg/**"
            "**/CVS/**"
            "**/.DS_Store/**"
            "**/node_modules/**"
            "**/bower_components/**"
            "**/.direnv/**"
          ];
        };
        description = "Configuration for tailwindcss-language-server.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the prettierd command.";
      };
    };

    extraConfig = cfg: {
      languages.css.enable = lib.mkDefault true;
      languages.html.enable = lib.mkDefault true;

      # Tailwind is often a plugin for other languages, but if there's a specific 'tailwind' filetype:
      plugins.conform-nvim.settings.formatters_by_ft.tailwind = ["prettierd"];

      plugins.lsp.servers.tailwindcss = {
        extraOptions = cfg.lsp.settings;
        cmd = cfg.lsp.command;
      };

      extraConfigLua = lib.mkIf cfg.lsp.enable ''
        do
          local tailwind = vim.lsp.config.tailwindcss
          local supported_filetypes = tailwind.filetypes or {}
          local get_language_id = tailwind.get_language_id

          -- Treat unfamiliar filetypes (e.g. Rust HTML macros) as HTML,
          -- while preserving native languages and explicit language mappings.
          tailwind.get_language_id = function(bufnr, filetype)
            local language = get_language_id and get_language_id(bufnr, filetype) or filetype
            local settings = tailwind.settings or {}
            local include_languages = (settings.tailwindCSS or {}).includeLanguages or {}
            if vim.tbl_contains(supported_filetypes, language) or include_languages[language] then
              return language
            end
            return "html"
          end

          -- Mutate the resolved config: a nil setup option would merely inherit
          -- nvim-lspconfig's default filetype restriction instead of clearing it.
          tailwind.filetypes = ${
          if cfg.lsp.filetypes == null
          then "nil"
          else lib.nixvim.toLuaObject cfg.lsp.filetypes
        }
        end
      '';
    };
  } {
    inherit pkgs lib config;
  }
