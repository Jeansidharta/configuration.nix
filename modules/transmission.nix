{ pkgs, ... }:
{
  users.users.sidharta.extraGroups = [ "transmission" ];

  services.transmission = {
    enable = true;
    openFirewall = true;
    package = pkgs.transmission_4;
  };
}
