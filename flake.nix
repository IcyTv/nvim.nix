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
        # Call the library function from the final flake outputs
        nvim = inputs.self.lib.${system}.makeNeovimWithLanguages {
          inherit pkgs;
          languages = {};
        };
      in {
        packages.default = nvim;

        devShells.default = pkgs.mkShellNoCC {
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
          rust = import ./config/languages/rust.nix;
          nix = import ./config/languages/nix.nix;
          shell = import ./config/languages/shell.nix;
        };

        # System-dependent library, created for each system
        lib = nixpkgs.lib.genAttrs supportedSystems (system: {
          makeNeovimWithLanguages = {
            pkgs,
            languages ? {},
          }:
            nixvim.legacyPackages.${system}.makeNixvimWithModule {
              inherit pkgs;
              module = [
                nixvimModules.default
                nixvimModules.rust
                nixvimModules.nix
                nixvimModules.shell
                # This module sets the configuration based on the function's input.
                {config.languages = languages;}
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
              nixvimModules.rust
              nixvimModules.nix
              nixvimModules.shell
            ];
          };
        };
      };
    };
}
