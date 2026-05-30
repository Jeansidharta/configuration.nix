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
  networking.wireguard.interfaces = {
    wg-lsbots = {
      ips = [
        "fd10::2/64"
        "10.1.0.2/16"
      ];
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
      privateKeyFile = config.age.secrets.wireguard-key.path;
    };
  };
}