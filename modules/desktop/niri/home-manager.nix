{
  config,
  pkgs,
  lib,
  theme,
  ...
}:
{
  programs.niri = {
    settings = {
      overview.zoom = 0.4;
      overview.backdrop-color = theme.colors.bg_dark;
      prefer-no-csd = true;
      screenshot-path = "~/screenshots-niri/%Y-%m-%d %H-%M-%S.png";
      hotkey-overlay = {
        skip-at-startup = true;
      };
      input.keyboard.xkb = {
        layout = "us";
        variant = "intl";
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

      binds =
        let
          niri = lib.getExe pkgs.niri-unstable;
          xargs = "${pkgs.findutils}/bin/xargs";
          jq = lib.getExe pkgs.jq;
          wezterm = lib.getExe pkgs.wezterm;
          leaderKey = "Super";
          wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
          grim = lib.getExe pkgs.grim;
          satty = lib.getExe pkgs.satty;
          wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
          vipe = "${pkgs.moreutils}/bin/vipe";
          neovim = "${pkgs.neovim}/bin/nvim";
          mpc = lib.getExe pkgs.mpc;

          modifyClipboard = pkgs.writeScript "write-script" ''
            ${wezterm} start -- bash -c "export EDITOR=${neovim} ; ${wl-paste} | ${vipe} | ${wl-copy} && exit"
          '';
          paste-qrcode = (
            let
              qrencode = lib.getExe pkgs.qrencode;
              sxiv = lib.getExe pkgs.sxiv;
            in
            pkgs.writeScript "qrcode" ''
              IMAGE_FILE=$(mktemp qrcode-XXX)
              ${wl-paste} | ${xargs} ${qrencode} -o "$IMAGE_FILE" && ${sxiv} -f -s f "$IMAGE_FILE"
              rm -f "$IMAGE_FILE"
            ''
          );
        in
        with config.lib.niri.actions;
        {
          "${leaderKey}+Return".action.spawn = wezterm;
          "${leaderKey}+Shift+Return".action.spawn = [
            wezterm
            "start"
            "--"
            "tmux"
          ];
          "${leaderKey}+Ctrl+Shift+Return".action.spawn = [
            wezterm
            "start"
            "--"
            "tmux"
            "attach"
          ];

          "${leaderKey}+Left".action = focus-column-left;
          "${leaderKey}+Right".action = focus-column-right;
          "${leaderKey}+Up".action = focus-window-up;
          "${leaderKey}+Down".action = focus-window-down;

          "${leaderKey}+shift+Left".action = move-column-left;
          "${leaderKey}+shift+Right".action = move-column-right;
          "${leaderKey}+Shift+Up".action = move-window-up;
          "${leaderKey}+Shift+Down".action = move-window-down;

          "${leaderKey}+ctrl+shift+Left".action = consume-or-expel-window-left;
          "${leaderKey}+ctrl+shift+Right".action = consume-or-expel-window-right;
          "${leaderKey}+ctrl+shift+Up".action = move-window-up;
          "${leaderKey}+ctrl+shift+Down".action = move-window-down;

          "${leaderKey}+j".action = focus-column-left;
          "${leaderKey}+l".action = focus-column-right;
          "${leaderKey}+i".action = focus-workspace-up;
          "${leaderKey}+k".action = focus-workspace-down;

          "${leaderKey}+shift+j".action = move-column-left;
          "${leaderKey}+shift+l".action = move-column-right;
          "${leaderKey}+Shift+i".action = move-window-to-workspace-up;
          "${leaderKey}+Shift+k".action = move-window-to-workspace-down;

          "${leaderKey}+F1".action = set-column-width "100%";
          "${leaderKey}+F2".action = set-column-width "50%";
          "${leaderKey}+F3".action = set-column-width "33%";
          "${leaderKey}+F4".action = set-column-width "25%";
          "${leaderKey}+F5".action = set-column-width "20%";
          "${leaderKey}+F6".action = set-column-width "16.66%";
          "${leaderKey}+F7".action = set-column-width "14.28%";
          "${leaderKey}+F8".action = set-column-width "12.5%";
          "${leaderKey}+F9".action = set-column-width "11.11%";
          "${leaderKey}+F10".action = set-column-width "0%";

          "${leaderKey}+Shift+F1".action = set-column-width "0%";
          "${leaderKey}+Shift+F2".action = set-column-width "50%";
          "${leaderKey}+Shift+F3".action = set-column-width "66%";
          "${leaderKey}+Shift+F4".action = set-column-width "75%";
          "${leaderKey}+Shift+F5".action = set-column-width "80%";
          "${leaderKey}+Shift+F6".action = set-column-width "83.33%";
          "${leaderKey}+Shift+F7".action = set-column-width "85.71%";
          "${leaderKey}+Shift+F8".action = set-column-width "87.5%";
          "${leaderKey}+Shift+F9".action = set-column-width "88.88%";
          "${leaderKey}+Shift+F10".action = set-column-width "100%";

          "${leaderKey}+Ctrl+F1".action = set-window-height "100%";
          "${leaderKey}+Ctrl+F2".action = set-window-height "50%";
          "${leaderKey}+Ctrl+F3".action = set-window-height "33%";
          "${leaderKey}+Ctrl+F4".action = set-window-height "25%";
          "${leaderKey}+Ctrl+F5".action = set-window-height "20%";
          "${leaderKey}+Ctrl+F6".action = set-window-height "16.66%";
          "${leaderKey}+Ctrl+F7".action = set-window-height "14.28%";
          "${leaderKey}+Ctrl+F8".action = set-window-height "12.5%";
          "${leaderKey}+Ctrl+F9".action = set-window-height "11.11%";
          "${leaderKey}+Ctrl+F10".action = set-window-height "0%";

          "${leaderKey}+Shift+Ctrl+F1".action = set-window-height "0%";
          "${leaderKey}+Shift+Ctrl+F2".action = set-window-height "50%";
          "${leaderKey}+Shift+Ctrl+F3".action = set-window-height "66%";
          "${leaderKey}+Shift+Ctrl+F4".action = set-window-height "75%";
          "${leaderKey}+Shift+Ctrl+F5".action = set-window-height "80%";
          "${leaderKey}+Shift+Ctrl+F6".action = set-window-height "83.33%";
          "${leaderKey}+Shift+Ctrl+F7".action = set-window-height "85.71%";
          "${leaderKey}+Shift+Ctrl+F8".action = set-window-height "87.5%";
          "${leaderKey}+Shift+Ctrl+F9".action = set-window-height "88.88%";
          "${leaderKey}+Shift+Ctrl+F10".action = set-window-height "100%";

          "${leaderKey}+equal".action = reset-window-height;

          "${leaderKey}+1".action = focus-workspace "browser";
          "${leaderKey}+2".action = focus-workspace "2";
          "${leaderKey}+3".action = focus-workspace "3";
          "${leaderKey}+4".action = focus-workspace "4";
          "${leaderKey}+5".action = focus-workspace "5";
          "${leaderKey}+6".action = focus-workspace "6";
          "${leaderKey}+7".action = focus-workspace "communication";
          "${leaderKey}+8".action = focus-workspace "gaming";
          "${leaderKey}+9".action = focus-workspace "x";

          "${leaderKey}+Shift+1".action.move-window-to-workspace = "browser";
          "${leaderKey}+Shift+2".action.move-window-to-workspace = "2";
          "${leaderKey}+Shift+3".action.move-window-to-workspace = "3";
          "${leaderKey}+Shift+4".action.move-window-to-workspace = "4";
          "${leaderKey}+Shift+5".action.move-window-to-workspace = "5";
          "${leaderKey}+Shift+6".action.move-window-to-workspace = "6";
          "${leaderKey}+Shift+7".action.move-window-to-workspace = "communication";
          "${leaderKey}+Shift+8".action.move-window-to-workspace = "gaming";
          "${leaderKey}+Shift+9".action.move-window-to-workspace = "x";

          "${leaderKey}+Home".action = focus-column-first;
          "${leaderKey}+End".action = focus-column-last;
          "${leaderKey}+Shift+Home".action = move-column-to-first;
          "${leaderKey}+Shift+End".action = move-column-to-last;
          "${leaderKey}+c".action = center-window;

          "${leaderKey}+f".action = maximize-column;
          "${leaderKey}+Shift+f".action = fullscreen-window;
          "${leaderKey}+q".action = close-window;
          "${leaderKey}+Shift+q".action.spawn-sh =
            "${niri} msg --json focused-window | ${jq} --raw-output .pid | ${xargs} kill -9";
          "${leaderKey}+tab".action = toggle-overview;

          "${leaderKey}+t".action = toggle-column-tabbed-display;

          "${leaderKey}+x".action = switch-focus-between-floating-and-tiling;
          "${leaderKey}+Shift+x".action = toggle-window-floating;

          "${leaderKey}+question".action = show-hotkey-overlay;

          "Print".action.spawn-sh =
            "${grim} - | ${satty} --filename - --initial-tool crop --output-filename \"/home/sidharta/screenshots-niri/%Y-%m-%d_%H:%M:%S.png\" --save-after-copy";
          "${leaderKey}+Ctrl+v".action.spawn = "${modifyClipboard}";
          "${leaderKey}+Shift+v".action.spawn = "${paste-qrcode}";
          "Shift+XF86AudioNext".action.spawn = [
            mpc
            "next"
          ];
          "Shift+XF86AudioPlay".action.spawn = [
            mpc
            "toggle"
          ];
          "Shift+XF86AudioPrev".action.spawn = [
            mpc
            "prev"
          ];
          "Shift+XF86AudioRaiseVolume".action.spawn = [
            mpc
            "volume"
            "+10"
          ];
          "Shift+XF86AudioLowerVolume".action.spawn = [
            mpc
            "volume"
            "+10"
          ];
        };
    };
  };
}
