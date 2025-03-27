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

  networking.firewall.allowedTCPPorts = [ 8202 ];
}
