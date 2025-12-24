#! Extra tools for manipulating nix-related things.

{ inputs, config, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixos-cli.nixosModules.nixos-cli
  ];

  services.nixos-cli = {
    enable = true;
    prebuildOptionCache = true;
    config = {
      use_nvd = true;
      apply = {
        use_nom = true;
      };
    };
  };

  nixpkgs.overlays = [
    (config.lib.overlay-helpers.overlay-flake "nsearch")
    inputs.nix-index-database.outputs.overlays.nix-index
  ];

  programs.nix-index-database.comma.enable = true;
  home-manager.users.sidharta.imports = [
    inputs.nix-index-database.outputs.homeModules.nix-index
    (
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          nh # A nix helper
          nix-output-monitor # Better output for nix build
          nix-tree # Show derivation dependencies
          nix-du # Show derivation file sizes
          nix-melt # Inspect flake.lock files
          nsearch # Search nixpkgs for packages
          nvd # Necessay for nixos-cli
        ];
      }
    )
  ];
}
