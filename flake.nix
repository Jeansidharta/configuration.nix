{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        darwin.follows = "";
      };
    };

    splatmoji = {
      url = "path:./derivations/splatmoji";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    neovim-with-plugins = {
      url = "github:jeansidharta/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    wallpaper-manager-unwrapped = {
      url = "path:/home/sidharta/projects/wallpaper-manager";
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
      self,
      nixpkgs-unstable,
      nixpkgs-stable,
      home-manager,
      agenix,

      splatmoji,
      neovim-with-plugins,
      wallpaper-manager-unwrapped,
      eww-bar-selector,
      bspwm-desktops-report,
      window-title-watcher,
      volume-watcher,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        obsidian =
          let
            system = "x86_64-linux";
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system;
            modules = [
              ./configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.sidharta = import ./home-manager/home.nix;
                  extraSpecialArgs = {
                    inherit self system;
                  };
                };
              }
              agenix.nixosModules.default
              {
                _module.args = {
                  inherit inputs;
                };
              }
              (import ./overlays.nix {
                inherit
                  system
                  splatmoji
                  nixpkgs-stable
                  nixpkgs-unstable
                  neovim-with-plugins
                  wallpaper-manager-unwrapped
                  ;
                eww-bar-selector-flake = eww-bar-selector;
                bspwm-desktops-report-flake = bspwm-desktops-report;
                window-title-watcher-flake = window-title-watcher;
                volume-watcher-flake = volume-watcher;
              })
            ];
          };
      };
    };
}
