{ pkgs, ... }:
{
  imports = [ ];

  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "true";
      enableBattery = "true";
      topBarMonitor = "0";
      enableMedia = "false";
    };
  };

  home.packages = [
    pkgs.brightnessctl # Control monitor/keyboard brightness
  ];
}
