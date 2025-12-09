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
    # Define a function that, given a system, creates the `makeNeovimWithLanguages` function.
    # This lets us share it between `perSystem` and `flake.lib`.
    mkMakeNeovimWithLanguages = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      {languages ? {}}:
        nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs;
          module = [
            self.nixvimModules.default
            self.nixvimModules.rust
            # more languages here
            # This module sets the configuration based on the function's input.
            {config.languages = languages;}
          ];
        };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];

      perSystem = {
        system,
        pkgs,
        ...
      }: let
        # Create the function for the current system
        makeNeovimWithLanguages = mkMakeNeovimWithLanguages system;
        # Build the default package using the function
        nvim = makeNeovimWithLanguages {};
      in {
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
          default = nixvim.lib.${system}.check.mkTestDerivationFromNvim {
            inherit nvim;
            name = "A nixvim configuration";
          };
        };
      };

      flake = {
        # Expose the `lib` at the top level, generating it for all systems.
        lib = flake-parts.lib.forAllSystems (system: {
          makeNeovimWithLanguages = mkMakeNeovimWithLanguages system;
        });

        # Modules for use in NixOS or with `makeNixvimWithModule`
        nixvimModules = {
          default = import ./config;
          rust = import ./config/languages/rust.nix;
        };

        # NixOS module to activate the nixvim configuration
        nixosModules.default = {
          config,
          lib,
          ...
        }: {
          # Import the main nixvim module for NixOS
          imports = [nixvim.nixosModules.default];

          # When programs.nixvim is enabled in the NixOS configuration,
          # import your custom nixvim modules.
          config = lib.mkIf config.programs.nixvim.enable {
            programs.nixvim.imports = [
              self.nixvimModules.default
              self.nixvimModules.rust
            ];
          };
        };
      };
    };
}
