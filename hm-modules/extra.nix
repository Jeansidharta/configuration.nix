{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    lmms # Music production
    inkscape # Vector image editor
    imhex # A very nice hex editor
    libreoffice # Office suite
    hyprpicker # Cool color picker
    quickshell
    transmission_4 # Bit torrent client
    zapzap # whatsapp client
    obsidian # Note taking app
  ];
}
