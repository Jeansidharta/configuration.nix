{ ... }:
{
  imports = [ ./nixos.nix ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
}
