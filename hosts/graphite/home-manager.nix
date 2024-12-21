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
