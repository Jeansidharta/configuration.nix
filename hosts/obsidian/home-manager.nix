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
  services.syncplay = {
    enable = true;
    disableReady = true;
    disableChat = true;
    port = 8202;
  };
}
