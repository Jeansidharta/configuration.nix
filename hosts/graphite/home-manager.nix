{ pkgs, ... }:
let
  rofi = "${pkgs.rofi-unwrapped}/bin/rofi";
  tmsu = "${pkgs.tmsu}/bin/tmsu";
  xargs = "${pkgs.findutils}/bin/xargs";
  feh = "${pkgs.feh}/bin/feh";

  select-wallpaper = pkgs.writeScriptBin "wallpaper" ''
    ${rofi} -dmenu -p "Tags query" | ${xargs} ${tmsu} --database ~/wallpapers/.tmsu/db files static and | sxiv -o - | ${xargs} ${feh} --bg-fill
  '';
in
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  programs.ewwCustom = {
    extraVariables = {
      enableBacklight = "true";
      enableBattery = "true";
    };
  };
  services.nitrogen.enable = true;

  home.packages = [
    pkgs.brightnessctl # Control monitor/keyboard brightness
    select-wallpaper
  ];

  programs.feh.enable = true;
  xsession.initExtra = ''
    test -f ~/.fehbg && ~/.fehbg
  '';
}
