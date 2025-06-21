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

  networking.firewall.allowedTCPPorts = [
    8202
    3000
    8000
    8080
  ];
  security.pki.certificateFiles = [ ../../mitmproxy-ca-cert.pem ];
}
