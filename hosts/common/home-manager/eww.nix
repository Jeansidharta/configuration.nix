{ pkgs, ... }:
{
  enable = true;
  configDir = ./eww/config;
  systemdService = true;
  package = pkgs.writeShellApplication {
    name = "eww";
    runtimeInputs = [
      pkgs.mypkgs.bspwm-desktops-report
      pkgs.mypkgs.window-title-watcher
      pkgs.mypkgs.volume-watcher
      pkgs.mypkgs.backlight
      pkgs.eww
      pkgs.bspwm
      pkgs.pulseaudio
      pkgs.pamixer
      pkgs.playerctl
      pkgs.systemd
      pkgs.rofi-unwrapped
      pkgs.findutils
      pkgs.bash
    ];
    text = ''
      ${pkgs.eww}/bin/eww "$@"
    '';
  };
}
