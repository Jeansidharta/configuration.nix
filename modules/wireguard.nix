{ inputs, config, ... }:
{
  networking.wireguard.interfaces = {
    wg-lsbots = {
      ips = [
        "fd10::2/64"
      ];
      peers = [
        {
          allowedIPs = [
            "fd10::1/128"
          ];
          endpoint = "vps.sidharta.xyz:51820";
          publicKey = "2r/6iSMNBnNOqDIYNfi5LhV8mNByIktrs7mDm5gbtCg=";
        }
      ];
      privateKeyFile = config.age.secrets.wireguard-key.path;
    };
  };
}