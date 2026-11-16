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

#### Go

```nix
languages.go.enable = true;
```

Enables `gopls` for completion, navigation, and diagnostics, `gofmt` for
formatting, and `golangci-lint` for linting via `nvim-lint`. Keep your project's Go
toolchain available on `PATH` (for example, via a devshell) so these tools can
load and analyze it.

Use `languages.go.lsp.settings` to configure gopls, or the standard package and
command overrides to use project-specific tools. Set `languages.go.format.package = null`
to use `gofmt` from `PATH`.

Linting respects your project's `.golangci.yml` or `.golangci.yaml` configuration
and runs on the existing lint events (buffer entry, save, and leaving insert mode)
or manually with `<leader>cl`. Set `languages.go.lint.enable = false` to disable it.
Use `languages.go.lint.package` and `languages.go.lint.command` to override the
linter; setting `lint.package = null` uses `golangci-lint` from `PATH`.

#### Astro

```nix
languages.astro.enable = true;
```

Enables the Astro language server and `prettierd` formatting for `.astro` files,
plus HTML, CSS, JavaScript/TypeScript, and JSON support. Treesitter highlighting
is already included. Use `languages.astro.lsp.settings` and
`languages.astro.lsp.command` to customize the language server, or the standard
LSP and formatter package overrides to use project-specific tools.

Install Prettier and its Astro plugin in your project:

```sh
npm install --save-dev prettier prettier-plugin-astro
```

Add the plugin to your Prettier configuration (merge with any existing settings):

```json
{
  "plugins": ["prettier-plugin-astro"]
}
```

`prettierd` uses the project's Prettier installation and plugin. Set
`languages.astro.format.enable = false` to disable Astro formatting.

#### Markdown and MDX

Enable either stack independently, or both:

```nix
languages.markdown.enable = true;
languages.mdx.enable = true;
```

Markdown enables `marksman`, `prettierd`, and `markdownlint-cli2` via `nvim-lint`
for the `markdown` and legacy `markdown.mdx` filetypes. MDX detects `.mdx` files
as the separate `mdx` filetype and enables `mdx_analyzer` (from
`pkgs.mdx-language-server`) plus `prettierd`, with no default linter. Marksman
does not attach to this `mdx` filetype, so enabling both avoids duplicate routing.
Neither stack enables the other; MDX does not automatically enable TypeScript,
ESLint, or the Astro language server, even in an Astro project.

Both stacks support `lsp.command` and `lsp.settings`, plus the standard LSP and
formatter package/command overrides. For example:

```nix
languages.mdx = {
  enable = true;
  lsp.package = null; # Use mdx-language-server from PATH.
  format.package = null; # Use prettierd from PATH.
};
languages.markdown.lint.enable = false;
```

Use `languages.markdown.lint.package` and `languages.markdown.lint.command` to
override `markdownlint-cli2`; its project configuration controls Markdown rules.
Set either stack's `lsp.enable` or `format.enable` to `false` to disable that tool.
MDX reuses the included Markdown Treesitter parser for baseline highlighting;
this does not provide full JSX highlighting.

For MDX type checking, add `mdx.checkMdx` to your project's `tsconfig.json`.
For Astro MDX content, configure the analyzer's parser plugins for frontmatter
and GFM when your content uses them (merge with existing configuration):

```json
{
  "include": ["src/**/*.mdx"],
  "mdx": {
    "checkMdx": true,
    "plugins": ["remark-frontmatter", "remark-gfm"]
  }
}
```

Install these parser plugins in the project, not in the editor configuration:

```sh
npm install --save-dev remark-frontmatter remark-gfm
```

Keep the project's TypeScript/MDX dependencies available to the language server.
These analyzer settings do not configure Astro's rendering pipeline. Imported
`.astro` components do not receive full Astro prop checking inside MDX;
`mdx_analyzer` does not replace Astro's tooling for `.astro` files.

#### Tailwind CSS in Any Filetype

Tailwind attaches to all filetypes by default, including Rust. Unknown filetypes
are treated as HTML for class completion; formatting is unchanged.

```nix
makeNeovimWithLanguages {
  inherit system pkgs;
  languages.tailwind = {
    enable = true;
    lsp.filetypes = null; # Default: all filetypes.
    # lsp.filetypes = ["html" "rust"]; # Alternatively, restrict attachment.
  };
}
```

Tailwind still requires a detectable project root and a Tailwind configuration
or CSS entry point. Set `lsp.filetypes = []` to prevent automatic attachment,
or `lsp.enable = false` to disable the Tailwind LSP entirely.

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
| **Go** | `gopls` | `gofmt` | `golangci-lint` | - | Uses the project's Go toolchain from `PATH`. |
| **C/C++** | `clangd` | `clang-format` | `clang-tidy` | - | Clangd configured with modern defaults. |
| **Zig** | `zls` | `zig fmt` | - | - | Supports `package` override. |
| **Python** | `basedpyright` | `ruff` | `ruff` | TOML | Uses `basedpyright` for strict types. |
| **JS/TS** | `ts_ls` | `prettierd` | `eslint_d` | JSON | |
| **Svelte** | `svelte` | `prettierd` | - | HTML, CSS, JS/TS, JSON | |
| **Astro** | `astro` | `prettierd` | - | HTML, CSS, JS/TS, JSON | Requires project-local `prettier` and `prettier-plugin-astro`. |
| **Markdown** | `marksman` | `prettierd` | `markdownlint-cli2` | - | Independent opt-in with `languages.markdown.enable`. |
| **MDX** | `mdx_analyzer` | `prettierd` | - | - | Independent opt-in with `languages.mdx.enable`; no automatic Astro LSP or TypeScript/ESLint stack. |
| **Tailwind** | `tailwindcss` | `prettierd` | - | HTML, CSS | |
| **HTML** | `html` | `prettierd` | - | - | |
| **CSS** | `cssls` | `prettierd` | `eslint_d` | - | |
| **JSON** | `jsonls` | `prettierd` | `jsonlint` | - | |
| **YAML** | `yamlls` | `prettierd` | `yamllint` | - | Schemastore enabled. |
| **TOML** | `taplo` | `taplo` | - | - | |
| **Nix** | `nixd` | `alejandra` | `statix`, `deadnix` | - | |
| **Shell** | `bashls` | `shfmt` | `shellcheck` | - | |
| **Lua** | `lua_ls` | `stylua` | `luacheck` | - | |
| **Haskell** | `hls` | `fourmolu`, `cabal-fmt` | `hlint` | YAML | Supports Cabal formatting and optional GHC installation via Nixvim. |

## License
MIT
