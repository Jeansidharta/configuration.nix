{ inputs, config, ... }:
{
  # services.resolved.dnsDelegates."lsbots.com.br".Delegate = {
  #   DNS = "fd10::1";
  #   Domains = "lsbots.com.br";
  # };
  # services.resolved.dnsDelegates."lsbots".Delegate = {
  #   DNS = "fd10::1";
  #   Domains = "lsbots";
  # };
  systemd.network.networks."40-wg-lsbots".extraConfig = ''
    [Network]
    Domains=lsbots.com.br
    DNS=[fd10::1]:53
  '';
  networking = {
    networkmanager.ensureProfiles = {
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
          dns-data = "10.1.0.1;";
          dns-search = "~lsbots.com.br";
          method = "manual";
        };
        ipv6 = {
          dns-data = "fd10::1";
          dns-search = "~lsbots.com.br";
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
              endpoint = "satha.lsbots.com.br:51820";
              publicKey = "2r/6iSMNBnNOqDIYNfi5LhV8mNByIktrs7mDm5gbtCg=";
            }
          ];
          privateKeyFile = config.age.secrets.wg-lsbots-key.path;
        };
      };
    };
  };
}