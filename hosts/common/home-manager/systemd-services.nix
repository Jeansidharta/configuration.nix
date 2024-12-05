{ pkgs, ... }:
let
  lib = pkgs.lib;
in
{
  eww-bar-selector =
    let
      path = pkgs.lib.strings.concatStringsSep ":" [
        "${pkgs.bspwm}/bin"
        "${pkgs.eww}/bin"
        "/bin"
      ];
    in
    {
      Unit = {
        Description = "Eww bar selector";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.mypkgs.eww-bar-selector}/bin/bar-selector";
        ExecSearchPath = path;
      };
    };

  eww =
    let
      path = lib.strings.concatStringsSep ":" [
        "${pkgs.mypkgs.bspwm-desktops-report}/bin"
        "${pkgs.mypkgs.window-title-watcher}/bin"
        "${pkgs.mypkgs.volume-watcher}/bin"
        "${pkgs.mypkgs.backlight}/bin"
        "${pkgs.eww}/bin"
        "${pkgs.bspwm}/bin"
        "${pkgs.pulseaudio}/bin"
        "${pkgs.pamixer}/bin"
        "${pkgs.playerctl}/bin"
        "${pkgs.systemd}/bin"
        "${pkgs.rofi-unwrapped}/bin"
        "${pkgs.findutils}/bin"
        "/bin"
      ];
    in
    {
      Unit = {
        Description = "Eww bar";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
        ExecSearchPath = path;
      };
    };
}
