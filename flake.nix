{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-xkbcommon.url = "github:NixOS/nixpkgs/c35a5a895f2517964e3e9be3d1eb8bb8c68db629";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    theme.url = "path:./theming";
    disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
    yazi-custom.url = "path:./derivations/yazi";
    plover-flake = {
      url = "github:dnaq/plover-flake";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.45.2";
    };
    hyprlock = {
      url = "github:hyprwm/hyprlock";
    };
    hypridle = {
      url = "github:hyprwm/hypridle";
    };
    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
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
    swww = {
      url = "github:LGFae/swww";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    workspaces-report = {
      url = "path:./derivations/workspaces-report";
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
      hyprland,
      plover-flake,
      nixpkgs-xkbcommon,
      swww,
      yazi-custom,
      hyprlock,
      hyprpicker,
      hypridle,
      envsub,
      splatmoji,
      neovim-with-plugins,
      eww-bar-selector,
      workspaces-report,
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
            plover-flake
            ;

          envsub-flake = envsub;
          backlight-flake = backlight;
          eww-bar-selector-flake = eww-bar-selector;
          workspaces-report-flake = workspaces-report;
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
                  hyprland.homeManagerModules.default
                  yazi-custom.homeManagerModules.default
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
        hyprland.nixosModules.default
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        ("${disko}/module.nix")
        (overlays system)
        {
          nixpkgs.overlays = [
            yazi-custom.overlays.default
            hyprlock.overlays.default
            hyprland.overlays.default
            hypridle.overlays.default
            hyprpicker.overlays.default
            swww.overlays.default
            (final: prev: {
              hyprlock = hyprlock.packages.${system}.default;
              hypridle = hypridle.packages.${system}.default;
              hyprland = hyprland.packages.${system}.default;

              xkbcommon-0-10-0 = nixpkgs-xkbcommon.legacyPackages.${system}.python311Packages.xkbcommon;
            })
          ];
        }
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
