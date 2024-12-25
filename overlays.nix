{
  system,
  splatmoji,
  nixpkgs-stable,
  nixpkgs-unstable,
  neovim-with-plugins,
  wallpaper-manager-unwrapped,

  eww-bar-selector-flake,
  backlight-flake,
  bspwm-desktops-report-flake,
  window-title-watcher-flake,
  volume-watcher-flake,
}:
{
  config,
  pkgs,
  lib,
  options,
  specialArgs,
  modulesPath,
}:

let
  system = "x86_64-linux";
  # rawPkgsStable = nixpkgs-stable.legacyPackages.${system};
  rawPkgsUnstable = nixpkgs-unstable.legacyPackages.${system};
  wallpaper-manager-raw = wallpaper-manager-unwrapped.defaultPackage.${system};

  eww-bar-selector = eww-bar-selector-flake.outputs.defaultPackage.${system};
  backlight = backlight-flake.outputs.defaultPackage.${system};
  bspwm-desktops-report = bspwm-desktops-report-flake.outputs.packages.${system}.default;
  window-title-watcher = window-title-watcher-flake.outputs.packages.${system}.default;
  volume-watcher = volume-watcher-flake.outputs.packages.${system}.default;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      pkgsUnstable = rawPkgsUnstable;
      splatmoji = splatmoji.packages.${system}.default;
      mypkgs = rec {
        inherit
          eww-bar-selector
          bspwm-desktops-report
          window-title-watcher
          volume-watcher
          backlight
          ;
        neovim = neovim-with-plugins.packages.${system}.default;
        wallpaper-manager = prev.callPackage (import ./derivations/wrappers/wallpaper-manager.nix) {
          package = wallpaper-manager-raw;
        };
        select-wallpaper = prev.callPackage (import ./derivations/wrappers/select-wallpaper.nix) {
          inherit wallpaper-manager;
        };
        select-wallpaper-static =
          prev.callPackage (import ./derivations/wrappers/select-wallpaper-static.nix)
            { inherit wallpaper-manager; };
      };
    })
  ];
}
