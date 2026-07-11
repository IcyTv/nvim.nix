{
  pkgs,
  lib,
  config,
  ...
}: let
  utils = import ./utils.nix {inherit lib;};
in
  utils.mkLang {
    name = "rust";
    description = "Enable Rust support";
    lsp = {
      server = "rust_analyzer";
      package = pkgs.rust-analyzer;
    };
    format = {
      tool = "rustfmt";
      package = pkgs.rustfmt;
    };

    extraOptions = {
      toolchain = lib.mkOption {
        type = with lib.types; nullOr package;
        default = null;
        description = "Rust toolchain package (e.g. pkgs.rust-bin.stable.latest.default) to use for both LSP and formatting.";
      };
    };

    extraLspOptions = {
      settings = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {
          cargo.allFeatures = true;
          check.command = "clippy";
        };
        description = "Configuration for rust-analyzer. See https://rust-analyzer.github.io/manual.html#configuration for options.";
      };
      command = lib.mkOption {
        type = with lib.types; nullOr (listOf str);
        default = null;
      };
      installCargo = lib.mkEnableOption "Install cargo globally" // {default = false;};
      installRustc = lib.mkEnableOption "Install rustc globally" // {default = false;};
      icyosSupport = lib.mkEnableOption "Automatically configure rust-analyzer for IcyOS workspaces" // {default = true;};
    };

    extraFormatOptions = {
      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = "Additional arguments to pass to the rustfmt command.";
      };
    };

    extraConfig = cfg: {
      languages.toml.enable = lib.mkDefault true;

      # Apply toolchain defaults if set
      languages.rust = lib.mkIf (cfg.toolchain != null) {
        lsp.package = lib.mkDefault cfg.toolchain;
        lsp.command = lib.mkDefault ["${cfg.toolchain}/bin/rust-analyzer"];
        format.package = lib.mkDefault cfg.toolchain;
        format.command = lib.mkDefault "${cfg.toolchain}/bin/rustfmt";
      };

      plugins.conform-nvim.settings.formatters."rustfmt".args = cfg.format.args;

      plugins.lsp.servers.rust_analyzer = {
        installCargo = cfg.lsp.installCargo;
        installRustc = cfg.lsp.installRustc;
        rustfmtPackage = lib.mkIf cfg.format.enable cfg.format.package;
        extraOptions = lib.mkMerge [
          {
            settings."rust-analyzer" = cfg.lsp.settings;
          }
          (lib.mkIf cfg.lsp.icyosSupport {
            on_new_config = lib.nixvim.mkRaw ''
              function(new_config, root_dir)
                local function parent(path)
                  return vim.fs.dirname(path)
                end

                local function find_icyos_root(path)
                  while path and path ~= "" do
                    if vim.uv.fs_stat(path .. "/targets/x86_64-icyos.json") then
                      return path
                    end

                    local next_path = parent(path)
                    if next_path == path then
                      return nil
                    end
                    path = next_path
                  end
                end

                local icyos_root = find_icyos_root(root_dir)
                if not icyos_root then
                  return
                end

                -- IcyOS has mixed-target Rust packages. Apply the custom OS
                -- target only to std-linked userland packages; kernel and early
                -- bootstrap crates use their own no_std targets.
                local userland = icyos_root .. "/userland/"
                if not vim.startswith(root_dir, userland) then
                  return
                end
                if root_dir:find("/userland/early%-init", 1, false)
                  or root_dir:find("/userland/loader", 1, false)
                  or root_dir:find("/userland/memory%-server", 1, false)
                then
                  return
                end

                local target = icyos_root .. "/targets/x86_64-icyos.json"
                new_config.settings = new_config.settings or {}
                new_config.settings["rust-analyzer"] = new_config.settings["rust-analyzer"] or {}
                local ra = new_config.settings["rust-analyzer"]

                ra.cargo = vim.tbl_deep_extend("force", ra.cargo or {}, {
                  target = target,
                  allFeatures = true,
                })
                ra.check = vim.tbl_deep_extend("force", ra.check or {}, {
                  command = "clippy",
                  workspace = false,
                  extraArgs = {
                    "--target", target,
                    "-Zbuild-std=std,core,compiler_builtins,alloc,panic_abort",
                    "-Zbuild-std-features=compiler-builtins-mem",
                  },
                })
              end
            '';
          })
        ];
        cmd = cfg.lsp.command;
      };
    };
  } {
    inherit pkgs lib config;
  }
