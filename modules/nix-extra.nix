#! Extra tools for manipulating nix-related things.

{ inputs, config, ... }:
{
  imports = [
    inputs.nixos-cli.nixosModules.nixos-cli
  ];

  programs.nixos-cli = {
    enable = true;
    option-cache.enable = false;
    settings = {
      use_nvd = true;
      apply = {
        use_nom = true;
      };
    };
  };

  nixpkgs.overlays = [
    (config.lib.overlay-helpers.overlay-flake "nsearch")
    (_: prev: { neix = inputs.neix.packages.${prev.stdenv.hostPlatform.system}.default; })
  ];

  programs.extra-container.enable = true;

  home-manager.users.sidharta.imports = [
    (
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          inputs.nix-index-database.outputs.packages.${pkgs.stdenv.hostPlatform.system}.comma-with-db
          inputs.nix-index-database.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nix-index-with-db
          nh # A nix helper
          nix-output-monitor # Better output for nix build
          nix-tree # Show derivation dependencies
          nix-du # Show derivation file sizes
          nix-melt # Inspect flake.lock files
          nsearch # Search nixpkgs for packages
          nvd # Necessay for nixos-cli
          nix-init # Easily find a project's hash
          neix # search nixpkgs for packages
        ];
      }
    )
  ];
}
