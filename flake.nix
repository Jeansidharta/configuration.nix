{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    theme.url = "path:./theming";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    splatmoji = {
      url = "path:./derivations/splatmoji";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    neovim-with-plugins = {
      url = "github:jeansidharta/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    envsub = {
      url = "path:./derivations/envsub";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    backlight = {
      url = "path:./hosts/common/home-manager/eww/scripts/backlight";
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
      theme,
      agenix,
      disko,
      nix-index-database,

      ghostty,
      envsub,
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

          ghostty-flake = ghostty;
          envsub-flake = envsub;
          backlight-flake = backlight;
          eww-bar-selector-flake = eww-bar-selector;
          bspwm-desktops-report-flake = bspwm-desktops-report;
          window-title-watcher-flake = window-title-watcher;
          volume-watcher-flake = volume-watcher;
        });

      home-manager-module =
        {
          hostname,
          main-user,
          imports,
        }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${main-user} = {
              imports =
                imports
                ++ import ./modules/home-manager/default.nix
                ++ [
                  theme.outputs.home-manager-module
                  ./hosts/common/home-manager/default.nix
                ];
            };
            extraSpecialArgs = {
              inherit hostname main-user;
            };
          };
        };
      common-modules = system: [
        ./hosts/common/configuration.nix
        ./hardware/target/hardware-configuration.nix
        ./hardware/target/disko-config.nix
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        ("${disko}/module.nix")
        (overlays system)
        agenix.nixosModules.default
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
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
            modules = (common-modules system) ++ [
              ./hosts/obsidian/configuration.nix
              (home-manager-module {
                inherit hostname main-user;
                imports = [
                  ./hosts/obsidian/home-manager.nix
                ];
              })
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
            modules = (common-modules system) ++ [
              ./hosts/graphite/configuration.nix
              (home-manager-module {
                inherit hostname main-user;
                imports = [
                  ./hosts/graphite/home-manager.nix
                ];
              })
            ];
          };
      };
    };
}
