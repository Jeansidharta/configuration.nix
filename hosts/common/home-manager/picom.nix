{ config, pkgs, ... }:
{
  enable = true;
  backend = "glx";
  fade = false;

  shadowExclude = [ "name *?= 'Eww'" ];

  settings = {
    blur = {
      method = "dual_kawase";
      kernel = "11x11gaussian";
      background = true;
      background-frame = true;
      background-fixed = true;
      kern = "3x3box";
      strength = 6;
    };

    blur-background-exclude = [
      "window_type = 'dock'"
      "class_g = 'Peek'"
      "class_g = 'Steam'"
      "name = 'Eww - wifi'"
    ];

    corner-radius = 8;
    shadow-radius = 8;
    active-opacity = 1;
    inactive-opacity = 1;
    frame-opacity = 1;
    ocapity-rule = [ "100:_NET_WM_STATE:32a = '_NET_WM_STATE_FULLSCREEN'" ];

    rounded-corners-exclude = [ "name *?= 'Eww'" ];
  };
}
