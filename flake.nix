{
  description = "IcyTv's neovim configuration. Built with nixvim and based on LazyVim.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixvim = {
      url = "github:/nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-parts,
    ...
  } @ inputs: let
    config = import ./config;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {inherit system;};
        nixvimLib = nixvim.lib.${system};
        nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
          pkgs = pkgs;
          module = config;
        };
      in {
        checks = {
          default = nixvimLib.check.mkTestDerivationFromNvim {
            inherit nvim;
            name = "A nixvim configuration";
          };
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
      };
    };
}
