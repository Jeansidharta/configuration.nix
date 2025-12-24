{ inputs, config, ... }:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;
in
{
  nixpkgs.overlays = [
    (mkUnstable "snapcast")
    (overlay-flake "sqlite-diagram")
    (final: prev: {
      neovim = inputs.neovim-with-plugins.packages.${prev.system}.default;
    })
  ];
}
