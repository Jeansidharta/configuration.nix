{ pkgs, ... }:
let
  rofi = "${pkgs.rofi-unwrapped}/bin/rofi";
  tmsu = "${pkgs.tmsu}/bin/tmsu --database ~/wallpapers/.tmsu/db";
  xargs = "${pkgs.findutils}/bin/xargs";
  feh = "${pkgs.feh}/bin/feh";

  select-wallpaper = pkgs.writeScriptBin "wallpaper" ''
    ${tmsu} tags --color never | ${rofi} -dmenu -p "Tags query" | ${xargs} ${tmsu} files | sxiv -o - | ${xargs} ${feh} --bg-fill
  '';
in
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "true";
      enableBattery = "true";
      enableMedia = "false";
    };
  };

  home.packages = [
    pkgs.brightnessctl # Control monitor/keyboard brightness
    select-wallpaper
  ];

  programs.waypaper = {
    enable = true;
    settings = {
      folder = "/home/sidharta/wallpapers";
      subfolders = true;
      sort = "random";
    };
  };
  services.swww = {
    enable = true;
    systemdService = true;
  };

  programs.feh.enable = true;
  xsession.initExtra = ''
    test -f ~/.fehbg && ~/.fehbg
  '';
}
