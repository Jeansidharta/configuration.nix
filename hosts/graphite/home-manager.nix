{ pkgs, ... }:
# rofi = "${pkgs.rofi-unwrapped}/bin/rofi";
# tmsu = "${pkgs.tmsu}/bin/tmsu --database ~/wallpapers/.tmsu/db";
# xargs = "${pkgs.findutils}/bin/xargs";

# select-wallpaper = pkgs.writeScriptBin "wallpaper" ''
# ${tmsu} tags --color never | ${rofi} -dmenu -p "Tags query" | ${xargs} ${tmsu} files | sxiv -o - | ${xargs} ${feh} --bg-fill
# '';
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "true";
      enableBattery = "true";
      topBarMonitor = "eDP-1";
      enableMedia = "false";
    };
  };

  home.packages = [
    pkgs.brightnessctl # Control monitor/keyboard brightness
  ];
}
