{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  time.timeZone = "US/Eastern";
  networking.hostName = "obsidian";

  programs.steam = {
    enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  users.groups.proxyuser = { };
  users.users.proxyuser = {
    name = "proxyuser";
    group = "proxyuser";
    openssh.authorizedKeys.keys = [
      # Raspberry PI
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDig6qJstpy9HOVdJkvhc15ywIdRwUiH5uZ7lbwNW0rZ jeansidharta@gmail.com"
      # My phone
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7Zp5PotpXLi0ZSby7zm1B2Ca6GyIL76Rew9zzDCTKu u0_a270@localhost"
    ];
    isNormalUser = true;
    extraGroups = [ ];
  };
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "sidharta"
        "proxyuser"
      ];
      UseDns = true;
    };
    extraConfig =
      let
        permitOpen = [
          "localhost:3000"
          "localhost:8202"
          "localhost:8000"
          "localhost:8080"
          "localhost:443"
          "localhost:80"
        ];
        permitOpenStr = lib.strings.concatStringsSep " " permitOpen;
      in
      ''
        Match User proxyuser
          PermitOpen ${permitOpenStr}
          PermitListen 2222
          ForceCommand echo 'This user is for TCP forwarding only. Allowed forwards are ${permitOpenStr}'
      '';
  };
  networking.firewall.allowedTCPPorts = [ 22 ];
  security.pki.certificateFiles = [ ../../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
