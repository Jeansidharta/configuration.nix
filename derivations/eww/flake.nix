{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    backlight = {
      url = "./scripts/backlight";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
    envsub = {
      url = "./scripts/envsub";
    };
    eww-bar-selector = {
      url = "./scripts/eww-bar-selector";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    volume-watcher = {
      url = "./scripts/volume-watcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    window-title-watcher = {
      url = "./scripts/window-title-watcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
    workspaces-report = {
      url = "./scripts/workspaces-report";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      eww-bar-selector,
      utils,
      backlight,
      envsub,
      volume-watcher,
      window-title-watcher,
      workspaces-report,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-stable = nixpkgs-stable.legacyPackages.${system};

        theme = import ./theme.nix;
        extra-variables = {
          inherit (theme)
            primary_color
            secondary_color
            tertiary_color
            quaternary_color
            quintenary_color
            base_text
            disabled
            error
            success
            ;
          topBarMonitor = "ASUS VH242H";
        };
        extra-files = {
          "colors.scss" = ''
            $color-fg: ${theme.bg_light};
            $color-pink: ${theme.pink};
            $color-red: ${theme.error};
            $color-error: ${theme.error};
            $color-success: ${theme.success};
            $color-orange: ${theme.orange};
            $color-orange-thin: ${theme.orange};
            $color-teal: ${theme.cyan};
            $color-green: ${theme.green};
            $color-blue: ${theme.blue};
            $color-purple: ${theme.purple};
            $color-grey: ${theme.gray};

            $color-base: ${theme.bg_lighter};
            $color-background: ${theme.bg_dark};
            $color-background-solid: ${theme.bg_dark};
          '';
        };

        custom-eww = pkgs.callPackage ./default.nix {
          backlight = backlight.outputs.packages.${system}.default;
          volume-watcher = volume-watcher.outputs.packages.${system}.default;
          window-title-watcher = window-title-watcher.outputs.packages.${system}.default;
          workspaces-report = workspaces-report.outputs.packages.${system}.default;
          envsub = envsub.outputs.packages.${system}.default;
          eww-bar-selector = eww-bar-selector.outputs.packages.${system}.default;

          pamixer = pkgs-stable.pamixer;

          inherit extra-files extra-variables;
        };
      in
      {
        packages.default = custom-eww;
      }
    )
    // {
      homeManagerModule = import ./hm-module.nix self;
    };
}
