{
  inputs,
  config,
  ...
}:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;
in
{
  nixpkgs.overlays = [
    (mkUnstable "snapcast")
    (mkUnstable "dgop")
    (mkUnstable "linuxPackages_latest")
    (mkUnstable "nchat")
    (mkUnstable "jujutsu")
    (mkUnstable "jjui")
    (overlay-flake "sqlite-diagram")
    (final: prev: {
      nchat =
        inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.nchat.overrideAttrs
          (prevAttrs: {
            nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.libpng.dev ];
          });
    })
    (final: prev: {
      neovim = inputs.neovim-with-plugins.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];
}
