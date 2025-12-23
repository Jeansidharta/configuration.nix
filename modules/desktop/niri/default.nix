{ inputs, ... }:
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
}
