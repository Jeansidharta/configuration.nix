{ pkgs, ... }:
let
  pidof = "${pkgs.procps}/bin/pidof";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in
{
  # services.hypridle = {
  #   enable = true;
  #   settings = {
  #     general = {
  #       # avoid starting multiple hyprlock instances.
  #       lock_cmd = "${pidof} hyprlock || ${hyprlock}";
  #       # lock before suspend.
  #       before_sleep_cmd = "${loginctl} lock-session";
  #       # to avoid having to press a key twice to turn on the display.
  #       after_sleep_cmd = "${hyprctl} dispatch dpms on";
  #     };
  #     listener = [
  #       {
  #         timeout = 2.5 * 60;
  #         # set monitor backlight to minimum.
  #         on-timeout = "${brightnessctl} -s set 10";
  #         # monitor backlight restore.
  #         on-resume = "${brightnessctl} -r";
  #       }
  #       {
  #         timeout = 5 * 60;
  #         # lock screen when timeout has passed
  #         on-timeout = "${loginctl} lock-session";
  #       }
  #
  #       {
  #         timeout = 5.5 * 60;
  #         # screen off when timeout has passed
  #         on-timeout = "${hyprctl} dispatch dpms off";
  #         # screen on when activity is detected after timeout has fired.
  #         on-resume = "${hyprctl} dispatch dpms on";
  #       }
  #       {
  #         timeout = 30 * 60;
  #         # suspend pc
  #         on-timeout = "${systemctl} suspend";
  #       }
  #     ];
  #   };
  # };
}
