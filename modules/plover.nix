{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      xkbcommon-0-10-0 =
        inputs.nixpkgs-xkbcommon.legacyPackages.${prev.stdenv.hostPlatform.system}.python311Packages.xkbcommon;
    })
  ];
}
