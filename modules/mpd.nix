{
  pkgs,
  lib,
  config,
  ...
}:
let
  hm-module =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        mpc # cli to controll the mpd daemon
      ];

      services.mpd = {
        enable = true;
        musicDirectory = "/home/sidharta/music";
        extraConfig = ''
          audio_output {
            type            "pipewire"
            name            "PipeWire Sound Server"
          }
        '';
      };
      programs.ncmpcpp.enable = true;
    };
in
{
  environment.systemPackages = [
  ];

  home-manager.users.sidharta.imports = [
    hm-module
  ];
}
