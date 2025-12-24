{ inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
    ./nixos.nix
    ./niri/default.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
}
