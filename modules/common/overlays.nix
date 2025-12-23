{ inputs, config, ... }:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;
in
{
  nixpkgs.overlays = [
    (mkUnstable "snapcast")
    (overlay-flake "sqlite-diagram")
    (final: prev: {
      neovim = inputs.neovim-with-plugins.packages.${prev.system}.base.override (prevNeovimConf: {
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
  ];
}
