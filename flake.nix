{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-xkbcommon.url = "github:NixOS/nixpkgs/c35a5a895f2517964e3e9be3d1eb8bb8c68db629";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    theme.url = "./theming";
    disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
    yazi-custom.url = "./derivations/yazi";
    plover-flake = {
      url = "github:dnaq/plover-flake/7586d37430266c16452b06ffbab36d66965f3a70";
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
      url = "./derivations/splatmoji";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    swww = {
      url = "github:LGFae/swww/a07595cf607ed512bc0e4b223d28e5ed91854214";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    neovim-with-plugins = {
      url = "github:jeansidharta/neovim-flake";
    };
    sqlite-diagram = {
      url = "./derivations/sqlite-diagram";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    envsub = {
      url = "./derivations/envsub";
      # inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    backlight = {
      url = "./hosts/common/home-manager/eww/scripts/backlight";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    workspaces-report = {
      url = "./derivations/workspaces-report";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    window-title-watcher = {
      url = "./derivations/window-title-watcher";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    eww-bar-selector = {
      url = "./derivations/eww-bar-selector";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    volume-watcher = {
      url = "./derivations/volume-watcher";
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
      plover-flake,
      nixpkgs-xkbcommon,
      swww,
      yazi-custom,
      envsub,
      splatmoji,
      neovim-with-plugins,
      eww-bar-selector,
      sqlite-diagram,
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
          sqlite-diagram-flake = sqlite-diagram;
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
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        ("${disko}/module.nix")
        (overlays system)
        {
          nixpkgs.overlays = [
            yazi-custom.overlays.default
            swww.overlays.default
            (final: prev: {
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
