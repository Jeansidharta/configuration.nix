{ pkgs, ... }:
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "true";
      enableBattery = "true";
    };
  };
  services.nitrogen.enable = true;

  home.packages = [
    pkgs.brightnessctl
  ];
}
