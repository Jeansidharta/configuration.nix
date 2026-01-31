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
    neix = {
      url = "github:Hovirix/neix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs-stable";
        darwin.follows = "";
      };
    };
    dms-plugins = {
      url = "github:AvengeMedia/dms-plugins";
      flake = false;
    };
    nsearch = {
      url = "github:niksingh710/nsearch";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    dank-material-shell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      url = "git+https://invent.kde.org/graphics/drawy";
      flake = false;
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
      self,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        obsidian = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
            inherit inputs;
          };
          modules = [ ./hosts/obsidian/configuration.nix ];
        };
        graphite = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
            inherit inputs;
          };
          modules = [ ./hosts/graphite/configuration.nix ];
        };
        calcite = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            ssh-pubkeys = import ./ssh-pubkeys.nix;
            inherit inputs;
          };
          modules = [ ./hosts/calcite/configuration.nix ];
        };
        basalt = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = {
            inherit nixos-raspberrypi;
            inherit inputs;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = [ ./hosts/basalt/configuration.nix ];
        };
        vivianite = nixos-raspberrypi.lib.nixosSystemFull {
          specialArgs = {
            inherit nixos-raspberrypi;
            inherit inputs;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = [ ./hosts/vivianite/configuration.nix ];
        };
        fixie = nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit nixos-raspberrypi;
            inherit inputs;
            ssh-pubkeys = import ./ssh-pubkeys.nix;
          };
          modules = [ ./hosts/fixie/configuration.nix ];
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
              inherit inputs;
            };

            modules = [
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
