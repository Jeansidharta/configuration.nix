{ ... }:
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
}
