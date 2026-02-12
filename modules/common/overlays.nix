{ inputs, config, ... }:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;
in
{
  nixpkgs.overlays = [
    (mkUnstable "snapcast")
    (mkUnstable "dgop")
    (mkUnstable "linuxPackages_latest")
    (overlay-flake "sqlite-diagram")
    (final: prev: {
      neovim = inputs.neovim-with-plugins.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];
}
