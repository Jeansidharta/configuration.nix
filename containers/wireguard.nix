{ lib, pkgs, ... }:
let
  wg = lib.getExe' pkgs.wireguard-tools "wg";

  mkNylonContainer =
    {
      container-name,
      container-config,
      ip_addr,
    }:
    let
      wireguard-name = "wg-${container-name}";
      key = "IGV92m53H7MHr4RdLVr+yVw80Kf3lL2nmnUKzlDj4kw=";
    in
    {
    };
in
mkNylonContainer "dns" "fd00::1" {
  privateNetwork = true;
  # hostBridge = "br-containers";
  config =
    { pkgs, ... }:
    {

      services.darkhttpd = {
        enable = true;
        rootDir = "/";
        port = 80;
      };
      # services.dnsmasq = {
      #   enable = true;
      #   settings = {
      #     no-resolv = true;
      #     bind-interface = true;
      #     interface = "wireguard-dns";
      #     server = [
      #       "1.1.1.1@eth0"
      #       "8.8.8.8@eth0"
      #     ];
      #   };
      # };
      environment.systemPackages = [
        pkgs.busybox
      ];
    };
}
