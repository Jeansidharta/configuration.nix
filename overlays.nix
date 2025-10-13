{
  system,
  splatmoji,
  nixpkgs-stable,
  nixpkgs-unstable,
  neovim-with-plugins,
  plover-flake,

  sqlite-diagram-flake,
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
      innernet = rawPkgsUnstable.innernet;
      mypkgs = {
        inherit
          sqlite-diagram
          ;
        neovim = neovim-with-plugins.packages.${system}.base.override (prev: {
          extraPackages = [
            pkgs.nil
            pkgs.prettierd
            pkgs.nodePackages_latest.bash-language-server
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
