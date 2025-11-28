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
    wiremix = {
      url = "github:tsowell/wiremix";
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
      wiremix,
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
        yazi-custom.overlays.default
        swww.overlays.default
        (mkUnstable "wezterm")
        (mkUnstable "quickshell")
        (mkUnstable "innernet")
        (mkUnstable "snapcast")
        (overlay-flake plover-flake "plover")
        (overlay-flake sqlite-diagram "sqlite-diagram")
        (overlay-flake splatmoji "splatmoji")
        (overlay-flake walker "walker")
        (overlay-flake wiremix "wiremix")
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

      common-hm-modules = (import ./modules/home-manager/default.nix) ++ [
        theme.outputs.home-manager-module
        ./hosts/common/home-manager/default.nix
        yazi-custom.homeManagerModules.default
        custom-eww.outputs.homeManagerModule
        custom-hyprland.outputs.homeConfigurations.default
        walker.outputs.homeManagerModules.default
      ];

      common-modules = [
        ./hosts/common/configuration.nix
        nix-index-database.nixosModules.nix-index
        home-manager.nixosModules.home-manager
        custom-hyprland.outputs.nixosConfigurations.default
        niri.nixosModules.niri
        ("${disko}/module.nix")
        agenix.nixosModules.default
        { nixpkgs.overlays = overlays; }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit (theme.outputs) theme;
            };
          };
        }
        {
          environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
        }
      ];
    in
    {
      nixosConfigurations = {
        obsidian = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = common-modules ++ [
            ./hosts/obsidian/configuration.nix
            "${nixpkgs-unstable}/nixos/modules/services/audio/snapserver.nix"
            {
              home-manager.users.sidharta.imports = common-hm-modules ++ [
                ./hosts/obsidian/home-manager.nix
              ];
            }
          ];
        };
        graphite = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = common-modules ++ [
            ./hosts/graphite/configuration.nix
            {
              home-manager.users.sidharta.imports = common-hm-modules ++ [
                ./hosts/obsidian/home-manager.nix
              ];
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
