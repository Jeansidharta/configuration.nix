{
  config,
  pkgs,
  lib,
  theme,
  ...
}:
{
  imports = [ ./binds.nix ];

  programs.niri = {
    settings = {
      overview.zoom = 0.4;
      overview.backdrop-color = theme.colors.bg_dark;
      prefer-no-csd = true;
      screenshot-path = "~/screenshots-niri/%Y-%m-%d %H-%M-%S.png";
      hotkey-overlay = {
        skip-at-startup = true;
      };
      input = {
        focus-follows-mouse = {
          enable = true;
          # max-scroll-amount = 0;
        };
        keyboard.xkb = {
          layout = "us";
          variant = "intl";
        };
      };
      clipboard = {
        disable-primary = false;
      };
      workspaces = {
        "browser" = { };
        "2" = { };
        "3" = { };
        "4" = { };
        "5" = { };
        "6" = { };
        "communication" = { };
        "gaming" = { };
        "x" = { };
      };
      animations = {
        workspace-switch = {
          enable = false;
        };
      };

      window-rules = [
        {
          draw-border-with-background = false;
          geometry-corner-radius = {
            bottom-left = 8.0;
            bottom-right = 8.0;
            top-left = 8.0;
            top-right = 8.0;
          };
          clip-to-geometry = true;
        }
        {
          matches = [ { app-id = "com.gabm.satty"; } ];
          open-fullscreen = true;
        }
        {
          matches = [ { app-id = "^steam.*$"; } ];
          open-on-workspace = "gaming";
        }
        {
          matches = [ { app-id = "^discord$"; } ];
          open-on-workspace = "communication";
        }
        {
          matches = [ { app-id = "^org\\.telegram\\.desktop$"; } ];
          open-on-workspace = "communication";
        }
        {
          matches = [ { app-id = "^ZapZap$"; } ];
          open-on-workspace = "communication";
        }
        {
          matches = [ { app-id = "wezterm.clipboard"; } ];
          open-focused = true;
          default-column-width = {
            proportion = 0.9;
          };
          default-window-height = {
            proportion = 0.9;
          };
          open-floating = true;
        }
      ];

      layout = {
        struts = {
          left = 4;
          right = 4;
        };
        tab-indicator = {
          width = 4;
          active = {
            color = theme.colors.tertiary_color;
          };
          urgent = {
            color = theme.colors.error;
          };
        };
        focus-ring = {
          width = 2;
          active = {
            color = theme.colors.primary_color;
          };
          urgent = {
            color = theme.colors.error;
          };
        };
      };
    };
  };
}
