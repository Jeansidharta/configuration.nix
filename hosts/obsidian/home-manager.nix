{ pkgs, ... }:
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "false";
      enableBattery = "false";
      topBarMonitor = "HDMI-A-1";
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
