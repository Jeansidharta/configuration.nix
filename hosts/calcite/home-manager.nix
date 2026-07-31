{ pkgs, ... }:
{
  imports = [ ];

  home.packages = [
    pkgs.brightnessctl # Control monitor/keyboard brightness
  ];
}
