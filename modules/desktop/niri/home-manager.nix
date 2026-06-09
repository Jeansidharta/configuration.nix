{
  config,
  pkgs,
  lib,
  theme,
  ...
}:
{
  imports = [
    ./binds.nix
  ];

  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            model = "";
            rules = "";
            variant = "intl";
          };
          repeat-delay = 600;
          repeat-rate = 25;
          track-layout = "global";
        };
        touchpad = {
          tap = { };
          natural-scroll = { };
        };
      };
      "output \"HDMI-A-1\"" = {
        focus-at-startup = { };
        transform = "normal";
        position = {
          _props = {
            x = 0;
            y = 0;
          };
        };
      };
      "output \"DP-1\"" = {
        transform = "normal";
        position = {
          _props = {
            x = 1920;
            y = 0;
          };
        };
      };
      screenshot-path = "~/screenshots-niri/%Y-%m-%d %H-%M-%S.png";
      prefer-no-csd = { };
      overview = {
        zoom = [ 0.4 ];
        backdrop-color = [ "#0d0d1a" ];
      };
      layout = {
        gaps = 2;
        struts = {
          left = 4;
          right = 4;
          top = 0;
          bottom = 0;
        };
        focus-ring = {
          width = 2;
          urgent-color = "#ff0055";
          active-color = "#ff66cc";
        };
        border = {
          off = { };
        };
        tab-indicator = {
          gap = 5;
          width = 5;
          length = {
            _props = {
              total-proportion = 0.5;
            };
          };
          position = "left";
          gaps-between-tabs = 0.000000;
          corner-radius = 0.000000;
          urgent-color = "#ff0055";
          active-color = "#00ffd5";
        };
        default-column-width = { };
        center-focused-column = "never";
      };
      cursor = {
        xcursor-theme = "default";
        xcursor-size = 24;
      };
      hotkey-overlay = {
        skip-at-startup = { };
      };
      _children = [
        {
          "workspace \"browser\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"communication\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"gaming\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"2\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"3\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"4\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"5\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"6\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          "workspace \"x\"" = {
            open-on-output = "HDMI-A-1";
          };
        }
        {
          window-rule = {
            draw-border-with-background = false;
            geometry-corner-radius = [
              4
              4
              4
              4
            ];
            clip-to-geometry = true;
            background-effect = {
              blur = true;
            };
          };
        }
        {
          window-rule = {
            match = {
              _props = {
                app-id = "com.gabm.satty";
              };
            };
            open-fullscreen = true;
          };
        }
        {
          window-rule = {
            match = {
              _props = {
                app-id = "^steam.*$";
              };
            };
            open-on-workspace = "gaming";
          };
        }
        {
          window-rule = {
            match = {
              _props = {
                app-id = "^discord$";
              };
            };
            open-on-workspace = "communication";
          };
        }
        {
          window-rule = {
            match = {
              _props = {
                app-id = "^org.telegram.desktop$";
              };
            };
            open-on-workspace = "communication";
          };
        }
        {
          window-rule = {
            match = {
              _props = {
                app-id = "wezterm.clipboard";
              };
            };
            default-column-width = {
              proportion = 0.9;
            };
            default-window-height = {
              proportion = 0.9;
            };
            open-floating = true;
            open-focused = true;
          };
        }
      ];
      animations = {
        workspace-switch = {
          off = { };
        };
      };
    };
  };
}
