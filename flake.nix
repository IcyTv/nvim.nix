{
  description = "IcyTv's neovim configuration. Built with nixvim and based on LazyVim.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:/nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-parts,
    ...
  } @ inputs: let
    # Define the list of systems once to share it
    supportedSystems = ["x86_64-linux"];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = supportedSystems;

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        unfreePkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # Call the library function from the final flake outputs
        nvim = inputs.self.lib.${system}.makeNeovimWithLanguages {
          pkgs = unfreePkgs;
          languages = {
            nix.enable = true;
          };
        };
      in {
        packages.default = nvim;

        devShells.default = unfreePkgs.mkShellNoCC {
          shellHook =
            #bash
            ''
              echo "Welcome to IcyTv's Neovim dev environment powered by NixVim"
              alias vim='nvim'
            '';
          packages = [nvim];
        };

        checks = {
          default = nixvim.lib.${system}.check.mkTestDerivationFromNvim {
            inherit nvim;
            name = "A nixvim configuration";
          };
        };
      };

      # Top-level, non-system-specific outputs
      flake = rec {
        # Nixvim modules used by the library function
        nixvimModules = {
          default = import ./config;
          prettier = import ./config/languages/prettier.nix;
          css = import ./config/languages/css.nix;
          rust = import ./config/languages/rust.nix;
          nix = import ./config/languages/nix.nix;
          shell = import ./config/languages/shell.nix;
          typescript = import ./config/languages/typescript.nix;
          tailwind = import ./config/languages/tailwind.nix;
          svelte = import ./config/languages/svelte.nix;
          toml = import ./config/languages/toml.nix;
          json = import ./config/languages/json.nix;
          yaml = import ./config/languages/yaml.nix;
          html = import ./config/languages/html.nix;
          c = import ./config/languages/c.nix;
          zig = import ./config/languages/zig.nix;
          python = import ./config/languages/python.nix;
          lua = import ./config/languages/lua.nix;
        };

        # System-dependent library, created for each system
        lib = nixpkgs.lib.genAttrs supportedSystems (system: {
          makeNeovimWithLanguages = {
            pkgs,
            languages ? {},
            extraConfig ? {},
          }:
            nixvim.legacyPackages.${system}.makeNixvimWithModule {
              inherit pkgs;
              module = [
                nixvimModules.default
                nixvimModules.prettier
                nixvimModules.css
                nixvimModules.rust
                nixvimModules.nix
                nixvimModules.shell
                nixvimModules.typescript
                nixvimModules.tailwind
                nixvimModules.svelte
                nixvimModules.toml
                nixvimModules.json
                nixvimModules.yaml
                nixvimModules.html
                nixvimModules.c
                nixvimModules.zig
                nixvimModules.python
                nixvimModules.lua
                # This module sets the configuration based on the function's input.
                {
                  config.languages = languages;
                  # Enable Nix by default as this is intended for devshells
                  config.languages.nix.enable = pkgs.lib.mkDefault true;
                }
                extraConfig
              ];
            };
        });

        # NixOS module to activate the nixvim configuration
        nixosModules.default = {
          config,
          lib,
          ...
        }: {
          imports = [nixvim.nixosModules.default];
          config = lib.mkIf config.programs.nixvim.enable {
            programs.nixvim.imports = [
              nixvimModules.default
              nixvimModules.prettier
              nixvimModules.css
              nixvimModules.rust
              nixvimModules.nix
              nixvimModules.shell
              nixvimModules.typescript
              nixvimModules.tailwind
              nixvimModules.svelte
              nixvimModules.toml
              nixvimModules.json
              nixvimModules.yaml
              nixvimModules.html
              nixvimModules.c
              nixvimModules.zig
              nixvimModules.python
              nixvimModules.lua
            ];
          };
        };
      };
    };
}
