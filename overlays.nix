{
  system,
  splatmoji,
  nixpkgs-stable,
  nixpkgs-unstable,
  neovim-with-plugins,
  plover-flake,

  envsub-flake,
  sqlite-diagram-flake,
  eww-bar-selector-flake,
  backlight-flake,
  workspaces-report-flake,
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
  ...
}:

let
  system = "x86_64-linux";
  # rawPkgsStable = nixpkgs-stable.legacyPackages.${system};
  rawPkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

  eww-bar-selector = eww-bar-selector-flake.outputs.packages.${system}.default;
  backlight = backlight-flake.outputs.defaultPackage.${system};
  workspaces-report = workspaces-report-flake.outputs.packages.${system}.default;
  window-title-watcher = window-title-watcher-flake.outputs.packages.${system}.default;
  volume-watcher = volume-watcher-flake.outputs.packages.${system}.default;
  envsub = envsub-flake.outputs.packages.${system}.default;
  plover = plover-flake.packages.${system}.plover;
  sqlite-diagram = sqlite-diagram-flake.packages.${system}.default;
in
{
  nixpkgs.overlays = [
    (final: prev: {
      inherit plover;
      wezterm = rawPkgsUnstable.wezterm;
      pkgsUnstable = rawPkgsUnstable;
      splatmoji = splatmoji.packages.${system}.default;
      quickshell = rawPkgsUnstable.quickshell;
      mypkgs = {
        inherit
          eww-bar-selector
          workspaces-report
          window-title-watcher
          volume-watcher
          backlight
          envsub
          sqlite-diagram
          ;
        neovim = neovim-with-plugins.packages.${system}.base.override (prev: {
          extraPackages = [
            pkgs.nil
            pkgs.prettierd
            pkgs.ripgrep
            pkgs.unixtools.xxd
            pkgs.marksman
            pkgs.zk
            pkgs.nixfmt-rfc-style
          ];
        });
      };
    })
  ];
}
