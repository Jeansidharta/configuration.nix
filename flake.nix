{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-xkbcommon.url = "github:NixOS/nixpkgs/c35a5a895f2517964e3e9be3d1eb8bb8c68db629";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
    theme.url = "./theming";
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
      nixos-generators,
      nixpkgs-stable,
      home-manager,
      theme,
      agenix,
      disko,
      drawy,
      nix-index-database,
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

      addon-modules = [
        nix-index-database.nixosModules.nix-index
        ("${disko}/module.nix")
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        { nixpkgs.overlays = overlays; }
        custom-hyprland.outputs.nixosConfigurations.default
        niri.nixosModules.niri
        {
          home-manager = {
            extraSpecialArgs = {
              inherit (theme.outputs) theme;
            };
            users.sidharta.imports = [
              theme.outputs.home-manager-module
              custom-eww.outputs.homeManagerModule
              custom-hyprland.outputs.homeConfigurations.default
              walker.outputs.homeManagerModules.default
            ];
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
          modules = addon-modules ++ [
            ./modules/common/default.nix
            ./modules/desktop/default.nix
            ./modules/extra.nix
            ./modules/nylon-wg.nix
            ./modules/proxyuser.nix
            ./modules/network-manager.nix

            ./secrets/module.nix

            ./hosts/obsidian/configuration.nix
            "${nixpkgs-unstable}/nixos/modules/services/audio/snapserver.nix"
          ];
        };
        graphite = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = addon-modules ++ [
            ./modules/common/default.nix
            ./modules/desktop/default.nix
            ./modules/nylon-wg.nix
            ./modules/network-manager.nix

            ./secrets/module.nix

            ./hosts/graphite/configuration.nix
          ];
        };
        basalt = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = {
            inherit nixos-raspberrypi;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          # nixpkgs = nixpkgs-stable;
          modules = addon-modules ++ [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
                sd-image
              ];
            }
            ./modules/common/default.nix
            ./modules/nylon-wg.nix
            ./modules/proxyuser.nix

            ./secrets/module.nix

            ./hosts/basalt/configuration.nix
          ];
        };
        vivianite = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = {
            inherit nixos-raspberrypi;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          # nixpkgs = nixpkgs-stable;
          modules = addon-modules ++ [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-4.base
                usb-gadget-ethernet
                sd-image
              ];
            }
            ./modules/common/default.nix
            ./modules/proxyuser.nix

            ./hosts/vivianite/configuration.nix
          ];
        };
        fixie = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit nixos-raspberrypi;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          # nixpkgs = nixpkgs-stable;
          modules = addon-modules ++ [
            ./modules/common/default.nix

            ./hosts/fixie/configuration.nix
          ];
        };
        calcite = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          # nixpkgs = nixpkgs-stable;
          modules = addon-modules ++ [
            ./modules/common/default.nix
            ./modules/desktop/default.nix
            ./modules/network-manager.nix
            ./secrets/module.nix

            ./hosts/calcite/configuration.nix
          ];
        };
      };
      sd-images = {
        basalt = self.nixosConfigurations.basalt.config.system.build.sdImage;
        vivianite = self.nixosConfigurations.vivianite.config.system.build.sdImage;
        fixie =
          let
            pkgs = nixpkgs-stable.legacyPackages."x86_64-linux";
            uboot = pkgs.callPackage ./hosts/fixie/uboot.nix { };
          in
          nixos-generators.nixosGenerate {
            system = "aarch64-linux";
            format = "sd-aarch64";
            specialArgs = {
              ssh-pubkeys = import ./ssh-pubkeys.nix;
            };

            modules = addon-modules ++ [
              ./modules/common/default.nix
              ./hosts/fixie/configuration.nix
              {
                # When building an image, flash the vendor's u-boot to the boot sector.
                sdImage.postBuildCommands = ''
                  echo Flashing vendor u-boot.bin to image
                  dd if=${uboot}/u-boot.bin of=$img bs=1 count=442 conv=notrunc
                  dd if=${uboot}/u-boot.bin of=$img bs=512 seek=1 skip=1 conv=notrunc
                '';
              }
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
