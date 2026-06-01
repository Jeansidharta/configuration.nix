{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.sidharta.extraGroups = [
    "netdev"
  ];

  # systemd.services.iwd.script = "${pkgs.writeScript "iwd-debug" ''
  #   #!${lib.getExe pkgs.bash}
  #   iwd --debug "$@"
  # ''}";

  disabledModules = [ "services/networking/iwd.nix" ];
  imports = [ ../options/iwd.nix ];

  networking = {
    useNetworkd = true;
    wireless = {
      userControlled.enable = true;
      enable = true;
    };
  };

  systemd = {
    # Improve journal logs
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";

    network = {
      enable = true;
      networks = {
        # ========== Default Interface Configs =========
        "90-ethernet-default-dhcp" = {
          matchConfig = {
            Type = "ether";
            Kind = "!*"; # physical interfaces have no kind
          };
          DHCP = "yes";
          networkConfig.IPv6PrivacyExtensions = "kernel";

          dhcpV4Config.RouteMetric = 1024;
          ipv6AcceptRAConfig.RouteMetric = 1024;
        };
        "90-wireless-client-dhcp" = {
          matchConfig.WLANInterfaceType = "station";
          DHCP = "yes";
          networkConfig.IPv6PrivacyExtensions = "kernel";
          # We also set the route metric to one more than the default
          # of 1024, so that Ethernet is preferred if both are
          # available.
          dhcpV4Config.RouteMetric = 1025;
          ipv6AcceptRAConfig.RouteMetric = 1025;
        };
      };
    };
  };
}