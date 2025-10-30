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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sqlite-diagram = {
      url = "./derivations/sqlite-diagram";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    custom-eww = {
      url = "./derivations/eww";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    custom-hyprland = {
      url = "./derivations/hyprland";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      splatmoji,
      neovim-with-plugins,
      custom-eww,
      custom-hyprland,
      sqlite-diagram,
      niri,
      walker,
      ...
    }:
    let
      /**
        Pulls the package from nixpkgs-unstable instead of stable.
      */
      mkUnstable =
        pkg-name:
        (prev: final: { ${pkg-name} = nixpkgs-unstable.legacyPackages.${prev.system}.${pkg-name}; });

      overlays = {
        nixpkgs.overlays =
          (import ./overlays.nix {
            inherit
              splatmoji
              nixpkgs-unstable
              neovim-with-plugins
              plover-flake
              ;

            sqlite-diagram-flake = sqlite-diagram;
          })
          ++ [
            niri.overlays.niri
            yazi-custom.overlays.default
            swww.overlays.default
            (mkUnstable "wezterm")
            (mkUnstable "quickshell")
            (mkUnstable "innernet")
            (final: prev: { walker = walker.packages.${prev.system}.default; })
            (final: prev: {
              xkbcommon-0-10-0 = nixpkgs-xkbcommon.legacyPackages.${prev.system}.python311Packages.xkbcommon;
            })
          ];
      };

      home-manager-module =
        {
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
                  custom-eww.outputs.homeManagerModule
                  custom-hyprland.outputs.homeConfigurations.default
                  walker.outputs.homeManagerModules.default
                ];
            };
            extraSpecialArgs = {
              inherit (theme.outputs) theme;
            };
          };
        };
      common-modules = [
        ./hosts/common/configuration.nix
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        custom-hyprland.outputs.nixosConfigurations.default
        niri.nixosModules.niri
        ("${disko}/module.nix")
        overlays
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
            main-user = "sidharta";
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system;
            modules = common-modules ++ [
              ./hosts/obsidian/configuration.nix
              (home-manager-module {
                inherit main-user;
                imports = [
                  ./hosts/obsidian/home-manager.nix
                ];
              })
            ];
          };
        graphite =
          let
            system = "x86_64-linux";
            main-user = "sidharta";
          in
          nixpkgs-stable.lib.nixosSystem {
            inherit system;
            modules = common-modules ++ [
              ./hosts/graphite/configuration.nix
              (home-manager-module {
                inherit main-user;
                imports = [
                  ./hosts/graphite/home-manager.nix
                ];
              })
            ];
          };
      };
      devShell.x86_64-linux =
        let
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          buildInputs = [
            pkgs.nil
            pkgs.nixfmt-rfc-style
          ];
        };
    };
}
