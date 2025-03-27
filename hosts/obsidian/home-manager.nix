{ pkgs, ... }:
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";

  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "false";
      enableBattery = "false";
    };
  };
  home.packages = [
    pkgs.orca-slicer
  ];
  services.syncplay = {
    enable = true;
    disableReady = true;
    disableChat = true;
    port = 8202;
  };
}
