{
  pkgs,
  lib,
  ssh-pubkeys,
  ...
}:
{
  imports = [
    ../modules/common/default.nix
    ../modules/systemd-networkd.nix
    ../modules/ssh-authorized-keys.nix
    ../secrets/module.nix
    # ../modules/podman.nix
  ];

  host-data.profile = "headless";

  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "sidharta"
        "root"
      ];
    };
  };

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      ssh-pubkeys.obsidian.sidharta
      ssh-pubkeys.phone
      ssh-pubkeys.graphite.sidharta
    ];
  };

  security.pki.certificateFiles = [ ../mitmproxy-ca-cert.pem ];
}
