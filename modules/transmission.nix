{ pkgs, ... }:
{
  users.users.sidharta.extraGroups = [ "transmission" ];

  services.transmission = {
    enable = true;
    openFirewall = true;
    package = pkgs.transmission_4;
    settings = {
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist = "127.0.0.1,::1,192.168.*.*";
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
    };
  };
}
