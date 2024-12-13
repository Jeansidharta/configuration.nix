{ pkgs, ... }:
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";

  services.wallpaper-manager.enable = true;

  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "false";
      enableBattery = "false";
    };
  };
  home.packages = [
    pkgs.orca-slicer

    pkgs.mypkgs.select-wallpaper
    pkgs.mypkgs.select-wallpaper-static
  ];
  services.syncplay = {
    enable = true;
    disableReady = true;
    disableChat = true;
    port = 8202;
  };
}
