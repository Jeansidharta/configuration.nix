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
    dhcp = "dhcpcd";
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
    ensureProfiles.secrets.entries = [
      {
        file = config.age.secrets.rede-mesh-psk.path;
        matchType = "802-11-wireless";
        matchId = "mesh-guest-static-ip";
        matchSetting = "802-11-wireless-security";
        key = "psk";
      }
    ];
    ensureProfiles.profiles = {
      mesh-guest-static-ip = {
        connection = {
          id = "mesh-guest-static-ip";
          type = "wifi";
          autoconnect-priority = 10;
        };

        wifi = {
          bssid = "3E:64:CF:AC:24:AF";
          mode = "infrastructure";
          ssid = "rede Mesh 99_Guest";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
        };
        ipv4 = {
          dns = "8.8.8.8;8.8.1.1;";
          gateway = "192.168.68.1";
          method = "manual";
        };

        ipv6 = {
          addr-gen-mode = "default";
          method = "link-local";
        };
      };
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
