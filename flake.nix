{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-xkbcommon.url = "github:NixOS/nixpkgs/c35a5a895f2517964e3e9be3d1eb8bb8c68db629";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    theme.url = "./theming";
    disko = {
      url = "github:nix-community/disko";
      flake = false;
    };
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
    wiremix = {
      url = "github:tsowell/wiremix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    drawy = {
      url = "github:Prayag2/drawy";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  # Optional: Binary cache for the flake
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    {
      nixpkgs-unstable,
      nixos-raspberrypi,
      nixpkgs-stable,
      home-manager,
      theme,
      agenix,
      disko,
      drawy,
      nix-index-database,
      plover-flake,
      nixpkgs-xkbcommon,
      swww,
      neovim-with-plugins,
      custom-eww,
      custom-hyprland,
      sqlite-diagram,
      niri,
      walker,
      wiremix,
      self,
      ...
    }:
    let
      /**
        Pulls the package from nixpkgs-unstable instead of stable.
      */
      mkUnstable =
        pkg-name:
        (final: prev: { ${pkg-name} = nixpkgs-unstable.legacyPackages.${prev.system}.${pkg-name}; });

      overlay-flake = flake: name: final: prev: {
        ${name} = flake.packages.${prev.system}.default;
      };

      overlays = [
        niri.overlays.niri
        swww.overlays.default
        (mkUnstable "wezterm")
        (mkUnstable "quickshell")
        (mkUnstable "snapcast")
        (overlay-flake plover-flake "plover")
        (overlay-flake sqlite-diagram "sqlite-diagram")
        (overlay-flake walker "walker")
        (overlay-flake drawy "drawy")
        (overlay-flake wiremix "wiremix")
        (overlay-flake agenix "agenix")
        (final: prev: {
          neovim = neovim-with-plugins.packages.${prev.system}.base.override (prevNeovimConf: {
            extraPackages = [
              prev.nil
              prev.prettierd
              prev.nodePackages_latest.bash-language-server
              prev.ripgrep
              prev.unixtools.xxd
              prev.marksman
              prev.zk
              prev.nixfmt-rfc-style
            ];
          });
        })
        (final: prev: {
          nylon-wg =
            nixpkgs-unstable.legacyPackages.${prev.system}.callPackage (import ./derivations/nylon-wg.nix)
              { };
        })
        (final: prev: {
          xkbcommon-0-10-0 = nixpkgs-xkbcommon.legacyPackages.${prev.system}.python311Packages.xkbcommon;
        })
      ];
      common-hm-modules-cli = [ ./hm-modules/cli.nix ];
      common-hm-modules-desktop = common-hm-modules-cli ++ [
        ./hm-modules/desktop.nix
        theme.outputs.home-manager-module
        custom-eww.outputs.homeManagerModule
        custom-hyprland.outputs.homeConfigurations.default
        walker.outputs.homeManagerModules.default
      ];

      common-modules = [
        ./modules/common.nix
        ./modules/nylon-wg.nix
        ./secrets/module.nix
        nix-index-database.nixosModules.nix-index
        ("${disko}/module.nix")
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        { nixpkgs.overlays = overlays; }
      ];

      desktop-modules = common-modules ++ [
        custom-hyprland.outputs.nixosConfigurations.default
        niri.nixosModules.niri
        (import ./modules/desktop.nix)
        {
          home-manager.extraSpecialArgs = {
            inherit (theme.outputs) theme;
          };
        }
      ];
    in
    {
      nixosConfigurations = {
        obsidian = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = desktop-modules ++ [
            ./hosts/obsidian/configuration.nix
            (import ./modules/proxyuser.nix)
            "${nixpkgs-unstable}/nixos/modules/services/audio/snapserver.nix"
            {
              home-manager.users.sidharta.imports = common-hm-modules-desktop ++ [
                ./hosts/obsidian/home-manager.nix
                ./hm-modules/extra.nix
              ];
            }
          ];
        };
        graphite = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = desktop-modules ++ [
            ./hosts/graphite/configuration.nix
            {
              home-manager.users.sidharta.imports = common-hm-modules-desktop ++ [
                ./hosts/graphite/home-manager.nix
              ];
            }
          ];
        };
        basalt = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = {
            inherit nixos-raspberrypi;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          # nixpkgs = nixpkgs-stable;
          modules = common-modules ++ [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                sd-image
              ];
            }
            {
              home-manager.users.sidharta.imports = common-hm-modules-cli;
            }
            (import ./modules/proxyuser.nix)
            (import ./hosts/basalt/configuration.nix)
          ];
        };
      };
      sd-images = {
        basalt = self.nixosConfigurations.basalt.config.system.build.sdImage;
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
