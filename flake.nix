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

      perSystem = {system, ...}: let
        unfreePkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # Call the library function from the final flake outputs
        nvim = inputs.self.lib.makeNeovimWithLanguages {
          inherit system;
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
      flake = let
        nixpkgsLib = nixpkgs.lib;
        languages = builtins.readDir ./config/languages;
        nixFiles = nixpkgsLib.filterAttrs (name: type: type == "regular" && nixpkgsLib.hasSuffix ".nix" name && name != "utils.nix") languages;
      in rec {
        # Nixvim modules used by the library function
        nixvimModules =
          {
            default = import ./config;
          }
          // nixpkgsLib.mapAttrs' (
            name: _:
              nixpkgsLib.nameValuePair
              (nixpkgsLib.removeSuffix ".nix" name)
              (import (./config/languages + "/${name}"))
          )
          nixFiles;

        # System-dependent library, created for each system
        lib.makeNeovimWithLanguages = {
          system,
          pkgs,
          languages ? {},
          extraConfig ? {},
        }:
          nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module =
              (builtins.attrValues nixvimModules)
              ++ [
                # This module sets the configuration based on the function's input.
                {config.languages = languages;}
                {config.languages.nix.enable = pkgs.lib.mkDefault true;}
                extraConfig
              ];
          };

        # NixOS module to activate the nixvim configuration
        nixosModules.default = {
          config,
          lib,
          ...
        }: {
          imports = [nixvim.nixosModules.default];
          config = lib.mkIf config.programs.nixvim.enable {
            programs.nixvim.imports = builtins.attrValues nixvimModules;
          };
        };
      };
    };
}
