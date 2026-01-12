# NixVim Configuration Flake

This repository exports a **highly opinionated**, modular Neovim configuration built with [NixVim](https://github.com/nix-community/nixvim).

## Features

*   **Battery-Included:** Comes with all [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter) grammars, Telescope, Git integration (Gitsigns, Fugitive), File explorer (Nvim-tree), and more pre-installed.
*   **Modular Languages:** Enable language support (LSP, Formatting, Linting) with a single boolean flag.
*   **Smart Defaults:** Enabling a language automatically enables relevant dependencies (e.g., enabling `svelte` also enables `html`, `css`, `javascript`, and `json`).
*   **Consistent Formatting:** Uses `prettierd` for web languages, `ruff` for Python, `rustfmt` for Rust, etc., with a "smart fallback" mechanism that respects project-specific configs.
*   **Opencode:** Includes the `opencode` plugin for AI assistance.

## Usage

This flake exports a library function `makeNeovimWithLanguages` and a NixOS module.

### 1. In a DevShell (Flake)

Use this to create a project-specific Neovim instance.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvim-config.url = "github:yourusername/nvim.nix"; # Replace with actual URL
  };

  outputs = { self, nixpkgs, nvim-config, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        (nvim-config.lib.${system}.makeNeovimWithLanguages {
          inherit pkgs;
          languages = {
            nix.enable = true;
            rust.enable = true;
            typescript.enable = true;
            python.enable = true;
          };
        })
      ];
    };
  };
}
```

### 2. On NixOS

Import the module and configure it via `programs.nixvim`.

```nix
{
  imports = [
    inputs.nvim-config.nixosModules.default
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    
    # Enable languages
    languages = {
      nix.enable = true;
      shell.enable = true;
      rust.enable = true;
    };
  };
}
```

## Configuration & Overrides

This configuration is **opinionated**. Most core plugins (Treesitter, Telescope, etc.) are enabled by default and cannot be easily disabled without forking. The primary configuration surface is the **languages** module.

### Language Options

Each language (e.g., `languages.rust`, `languages.c`) supports the following standard options:

*   `enable` (bool): Enable the language stack.

**Note:** `languages.nix` is enabled by default (via `mkDefault`) since this configuration is primarily designed for Nix-based development workflows. You can disable it explicitly by setting `languages.nix.enable = false`.

*   `lsp.enable` (bool): Enable LSP support (default: true).
*   `lsp.package` (package): Override the LSP package (set to `null` to use PATH).
*   `format.enable` (bool): Enable auto-formatting (default: true).
*   `format.package` (package): Override the formatter package.
*   `format.command` (string): Override the format command.
*   `lint.enable` (bool): Enable linting (default: true).
*   `lint.package` (package): Override the linter package.
*   `lint.command` (string): Override the lint command.

### Examples

#### Overriding Clangd Flags (C/C++)

```nix
languages.c = {
  enable = true;
  lsp.command = [
    "clangd"
    "--background-index"
    "--clang-tidy"
    "--header-insertion=never" # Custom flag
  ];
};
```

#### Using a Custom Rust Toolchain (Overlay)

For languages like Rust and Zig, you often need the LSP and Formatter to match a specific compiler version. Use the `toolchain` option.

```nix
# Assuming you have fenix or rust-overlay in your flake inputs
languages.rust = {
  enable = true;
  # This sets both LSP and Formatter to use this specific toolchain package
  toolchain = pkgs.rust-bin.stable.latest.default; 
};
```

#### Zig Version Matching

Zig requires `zls` (Language Server) and `zig` (Compiler) to match versions closely.

```nix
languages.zig = {
  enable = true;
  package = pkgs.zig; # Will use this for 'zig fmt'
  lsp.package = pkgs.zls; # Ensure this matches the zig version!
};
```
*Note: The flake will print a warning during evaluation if it detects a version mismatch between `zls` and `zig`.*

#### Adding Custom Config

You can inject arbitrary NixVim configuration using `extraConfig` in the library function.

```nix
makeNeovimWithLanguages {
  inherit pkgs;
  languages = { ... };
  extraConfig = {
    plugins.startup.enable = false; # Disable a default plugin if needed
    keymaps = [
      { key = "<leader>m"; action = ":echo 'My Custom Key'<CR>"; }
    ];
  };
}
```

## Supported Languages

| Language | LSP | Formatter | Linter | Enabled Dependencies | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Rust** | `rust-analyzer` | `rustfmt` | `cargo check` | TOML | Supports `toolchain` override. |
| **C/C++** | `clangd` | `clang-format` | `clang-tidy` | - | Clangd configured with modern defaults. |
| **Zig** | `zls` | `zig fmt` | - | - | Supports `package` override. |
| **Python** | `basedpyright` | `ruff` | `ruff` | TOML | Uses `basedpyright` for strict types. |
| **JS/TS** | `ts_ls` | `prettierd` | `eslint_d` | JSON | |
| **Svelte** | `svelte` | `prettierd` | - | HTML, CSS, JS/TS, JSON | |
| **Tailwind** | `tailwindcss` | `prettierd` | - | HTML, CSS | |
| **HTML** | `html` | `prettierd` | - | - | |
| **CSS** | `cssls` | `prettierd` | `eslint_d` | - | |
| **JSON** | `jsonls` | `prettierd` | `jsonlint` | - | |
| **YAML** | `yamlls` | `prettierd` | `yamllint` | - | Schemastore enabled. |
| **TOML** | `taplo` | `taplo` | - | - | |
| **Nix** | `nixd` | `alejandra` | `statix`, `deadnix` | - | |
| **Shell** | `bashls` | `shfmt` | `shellcheck` | - | |
| **Lua** | `lua_ls` | `stylua` | `luacheck` | - | |

## License
MIT
