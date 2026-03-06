{
  pkgs,
  lib,
  config,
  ...
}:
{
  systemd = {
    timers.dont-drop-me-arp = {
      timerConfig = {
        OnBootSec = "1s";
        OnUnitActiveSec = "1m";
      };
    };
    services.dont-drop-me-arp = {
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "dont-drop-me-arp" ''
          ${lib.getExe pkgs.arping} -U -c 1 192.168.68.1
        '';
      };
    };
  };
  networking.networkmanager = {
    enable = true;
    dispatcherScripts = [
      {
        source = pkgs.writeShellScript "enable-arper" ''
          echo "Connection: $CONNECTION_ID; if: $1; mode: $2"
          if [ "$CONNECTION_ID" != "mesh-guest-static-ip" ]; then
            exit 0
          fi

          if [ $2 == "up" ]; then
            echo "Enabling ARP timer"
            systemctl start dont-drop-me-arp.timer
          elif [ $2 == "down" ]; then
            echo "Disabling ARP timer"
            systemctl stop dont-drop-me-arp.timer
            # systemctl disable dont-drop-me-arp.timer
          fi
        '';
      }
    ];
    ensureProfiles.profiles = {
      wired-local-link = {
        connection = {
          id = "wired-local-link";
          type = "ethernet";
          autoconnect = true;
        };
        ipv4 = {
          method = "disabled";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "link-local";
        };
      };
    };
  };
  users.users.sidharta = {
    extraGroups = [
      "networkmanager"
    ];
  };
}
