{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        darwin.follows = "";
      };
    };
    secrets = {
      url = "path:./secrets";
    };

    splatmoji = {
      url = "path:./derivations/splatmoji";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    neovim-with-plugins = {
      url = "github:jeansidharta/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    backlight = {
      url = "path:./home-manager/configuration/eww/scripts/backlight";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    wallpaper-manager-unwrapped = {
      url = "github:jeansidharta/wallpaper-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    bspwm-desktops-report = {
      url = "path:./derivations/bspwm-desktops-report";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    window-title-watcher = {
      url = "path:./derivations/window-title-watcher";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    eww-bar-selector = {
      url = "path:./derivations/eww-bar-selector";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    volume-watcher = {
      url = "path:./derivations/volume-watcher";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      nixpkgs-unstable,
      nixpkgs-stable,
      home-manager,
      agenix,
      disko,

      splatmoji,
      neovim-with-plugins,
      wallpaper-manager-unwrapped,
      eww-bar-selector,
      bspwm-desktops-report,
      window-title-watcher,
      volume-watcher,
      backlight,
      ...
    }:
    let

      overlays =
        system:
        (import ./overlays.nix {
          inherit
            system
            splatmoji
            nixpkgs-stable
            nixpkgs-unstable
            neovim-with-plugins
            wallpaper-manager-unwrapped
            ;
          backlight-flake = backlight;
          eww-bar-selector-flake = eww-bar-selector;
          bspwm-desktops-report-flake = bspwm-desktops-report;
          window-title-watcher-flake = window-title-watcher;
          volume-watcher-flake = volume-watcher;
        });
    in
    {
      nixosConfigurations = {
        obsidian =
          let
            system = "x86_64-linux";
            hostname = "obsidian";
            main-user = "sidharta";
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/common/configuration.nix
              ./hosts/obsidian/configuration.nix
              home-manager.nixosModules.home-manager
              (import ./home-manager/nixos-module.nix { inherit hostname main-user; })
              ("${disko}/module.nix")
              (overlays system)
              agenix.nixosModules.default
            ];
          };
        graphite =
          let
            system = "x86_64-linux";
            hostname = "graphite";
            main-user = "sidharta";
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system;
            modules = [
              ./hosts/common/configuration.nix
              ./hosts/graphite/configuration.nix
              home-manager.nixosModules.home-manager
              (import ./home-manager/nixos-module.nix { inherit hostname main-user; })
              ("${disko}/module.nix")
              (overlays system)
              agenix.nixosModules.default
            ];
          };
      };
    };
}
