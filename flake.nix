{
  description = "IcyTv's neovim configuration. Built with nixvim and based on LazyVim.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:/nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    nixvim,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        nixvimLib = nixvim.lib.${system};

        # Function to build a neovim derivation with specific languages
        makeNeovimWithLanguages = {languages ? {}}:
          nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = [
              self.nixvimModules.default
              self.nixvimModules.rust
              # more languages here
              {
                _module.args = {inherit pkgs;};
                config.languages = languages;
              }
            ];
          };

        # The default package is a bare-bones neovim without any languages
        nvim = makeNeovimWithLanguages {};
      in {
        lib = {
          # Expose the function to other flakes
          inherit makeNeovimWithLanguages;
        };

        packages = {
          default = nvim;
        };

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
          default = nixvimLib.check.mkTestDerivationFromNvim {
            inherit nvim;
            name = "A nixvim configuration";
          };
        };
      };

      # Modules for use in NixOS or with `makeNixvimWithModule`
      nixvimModules = {
        default = import ./config;
        rust = import ./config/languages/rust.nix;
      };

      nixosModules = self.nixvimModules;
    };
}
