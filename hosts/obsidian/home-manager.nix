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

  programs.ssh.matchBlocks = {
    "nb" = {
      hostname = "192.168.0.118";
      user = "sidharta";
      port = 22;
    };
    "rpi" = {
      hostname = "192.168.0.210";
      user = "sidharta";
      port = 22;
    };
    "graphite" = {
      hostname = "192.168.0.186";
      user = "sidharta";
      port = 22;
    };
    "fixie" = {
      hostname = "192.168.0.140";
      user = "fixie";
      port = 22;
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
