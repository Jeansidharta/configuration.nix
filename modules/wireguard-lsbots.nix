{ config, lib, ... }:
{
  networking = {
    hosts = {
      "10.1.0.1" = [
        "git.lsbots.com.br"
        "icinga.lsbots.com.br"
        "wiki.lsbots.com.br"
        "matrix.lsbots.com.br"
      ];
    };
    networkmanager.ensureProfiles = lib.mkIf (config.networking.networkmanager.enable) {
      environmentFiles = [ config.age.secrets.wg-lsbots-key.path ];
      secrets.entries = [
        {
          file = config.age.secrets.wg-lsbots-key.path;
          key = "private-key";
          matchId = "wg-lsbots";
          matchSetting = "wireguard";
          matchType = "wireguard";
        }
      ];
      profiles.wg-lsbots = {
        connection = {
          id = "wg-lsbots";
          type = "wireguard";
          interface-name = "wg-lsbots";
        };
        wireguard = {
          # private-key-flags = 1; # Use secret from agent
          private-key = "$WG_LSBOTS_KEY";
        };
        "wireguard-peer.2r/6iSMNBnNOqDIYNfi5LhV8mNByIktrs7mDm5gbtCg=" = {
          endpoint = "147.15.70.235:51820"; # Should be satha.lsbots.com.br
          allowed-ips = "10.1.0.1/16;fd10::1/64;";
        };
        ipv4 = {
          method = "manual";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "manual";
        };
      };
    };
    wireguard = {
      useNetworkd = true;
      interfaces = {
        wg-lsbots = {
          peers = [
            {
              allowedIPs = [
                "fd10::1/64"
                "10.1.0.0/16"
              ];
              endpoint = "147.15.70.235:51820"; # satha.lsbots.com.br
              publicKey = "2r/6iSMNBnNOqDIYNfi5LhV8mNByIktrs7mDm5gbtCg=";
              persistentKeepalive = 30;
            }
          ];
          privateKeyFile = config.age.secrets.wg-lsbots-key.path;
        };
      };
    };
  };
}