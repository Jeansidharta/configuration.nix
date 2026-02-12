{ ... }:
{
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    mesh-guest-static-ip = {
      connection = {
        id = "mesh-guest-static-ip";
        type = "wifi";
        autoconnect = "no";
      };

      wifi = {
        bssid = "3E:64:CF:AC:24:AF";
        mode = "infrastructure";
        ssid = "rede Mesh 99_Guest";
      };
      ipv4 = {
        dns = "1.1.1.1;8.8.8.8;";
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
        autoconnect = "yes";
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
  users.users.sidharta = {
    extraGroups = [
      "networkmanager"
    ];
  };
}
