{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;

    settings =
      let
        hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
        satty = "${pkgs.satty}/bin/satty";
        jq = "${pkgs.jq}/bin/jq";
        hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
        wezterm = "${pkgs.wezterm}/bin/wezterm";
        mpc = "${pkgs.mpc}/bin/mpc";
        # notifySend = "${pkgs.libnotify}/bin/notify-send";
        vipe = "${pkgs.moreutils}/bin/vipe";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        neovim = "${pkgs.neovim}/bin/nvim";
        xargs = "${pkgs.findutils}/bin/xargs";

        leaderKey = "Super_L";
        paste-qrcode = (
          let
            wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
            qrencode = "${pkgs.qrencode}/bin/qrencode";
            sxiv = "${pkgs.sxiv}/bin/sxiv";
          in
          pkgs.writeScript "qrcode" ''
            IMAGE_FILE=$(mktemp qrcode-XXX)
            ${wl-paste} | ${xargs} ${qrencode} -o "$IMAGE_FILE" && ${sxiv} -f -s f "$IMAGE_FILE"
            rm -f "$IMAGE_FILE"
          ''
        );

        modifyClipboard = pkgs.writeScript "write-script" ''
          ${wezterm} start -- bash -c "export EDITOR=${neovim} ; ${wl-paste} | ${vipe} | ${wl-copy} && exit"
        '';
      in
      {
        general = {
          layout = "scrolling";
          no_focus_fallback = true;
          resize_on_border = true;
          snap = {
            enabled = true;
          };
        };
        decoration = {
          rounding = 8;
          blur = {
            passes = 2;
            xray = true;
          };
        };
        input = {
          follow_mouse = 2;
          natural_scroll = false;
          # Pulled from here:
          # https://github.com/sulmone/X11/blob/master/share/X11/xkb/rules/base.lst
          # kb_model = "pc105";
          kb_layout = "us";
          kb_variant = "intl";
          # kb_options = "grp:caps_toggle";
        };
        misc = {
          disable_autoreload = true;
          mouse_move_focuses_monitor = false;
          exit_window_retains_fullscreen = true;
        };
        scrolling = {
        };
        bezier = [
          "easeInBack, 0.6, -0.28, 0.735, 0.045"
          "easeInSine, 0.12, 0, 0.39, 0"
        ];
        animation = [
          "global, 1, 1, easeInBack"

          "border, 0"

          "windowsMove, 1, 1, easeInSine"

          "workspacesIn, 0"
          "workspacesOut, 0"
        ];
        monitor = [
          # General rule so any new monitor is properly placed
          ", preferred, auto, 1"
          "HDMI-A-1, preferred, 0x0, 1"
          "HDMI-A-2, preferred, 19200x10800, 1, transform, 1"
        ];
        layerrule = [
          "match:class quickshell, no_anim true"
        ];
        windowrule = [
          # Hide helldivers unnecessary window
          "match:initial_class steam_app_553850, match:initial_title negative:(.+), workspace special:hidden silent"

          # Smart Gaps
          "match:workspace w[tv1]s[false], match:float false, border_size 0, rounding 0"
          "match:workspace f[1]s[false], match:float false, border_size 0, rounding 0"
        ];
        bindm = [
          "${leaderKey}, mouse:272, movewindow"
          "${leaderKey}, mouse:273, resizewindow"
        ];
        workspace = [
          # Smrt Gaps
          "w[tv1]s[false], gapsout:0, gapsin:0"
          "f[1]s[false], gapsout:0, gapsin:0"

          "1, monitor:HDMI-A-1, defaultName:1"
          "2, monitor:HDMI-A-1, defaultName:2"
          "3, monitor:HDMI-A-1, defaultName:3"
          "4, monitor:HDMI-A-1, defaultName:4"
          "5, monitor:HDMI-A-1, defaultName:5"
          "6, monitor:HDMI-A-1, defaultName:6"
          "7, monitor:HDMI-A-1, defaultName:7"
          "8, monitor:HDMI-A-1, defaultName:8"
          "9, monitor:HDMI-A-1, defaultName:9"
          "10, monitor:HDMI-A-2, defaultName:1"
          "11, monitor:HDMI-A-2, defaultName:2"
          "12, monitor:HDMI-A-2, defaultName:3"
          "13, monitor:HDMI-A-2, defaultName:4"
          "14, monitor:HDMI-A-2, defaultName:5"
          "15, monitor:HDMI-A-2, defaultName:6"
          "16, monitor:HDMI-A-2, defaultName:7"
          "17, monitor:HDMI-A-2, defaultName:8"
          "18, monitor:HDMI-A-2, defaultName:9"
        ];
        bind = [
          ", Print, exec, ${hyprshot} --mode region --raw | ${satty} --filename -"
          "${leaderKey}&Control_L, v, exec, ${modifyClipboard}"
          "${leaderKey}&Shift_L  , v, exec, ${paste-qrcode}"
          "${leaderKey}&Shift_L  , x, togglefloating"
          "${leaderKey}          , x, exec, if ${hyprctl} -j activewindow | ${jq} --exit-status .floating; then ${hyprctl} dispatch cyclenext tiled hist; else ${hyprctl} dispatch cyclenext floating hist; fi"
          "${leaderKey}          , q, killactive, "
          "${leaderKey}&Shift_L  , q, forcekillactive, "
          "${leaderKey}          , Return, exec, ${wezterm}"

          "${leaderKey}          , f, fullscreenstate, 1 1 toggle"
          "${leaderKey}&Shift_L  , f, fullscreenstate, 2 0 toggle"
          "${leaderKey}&Ctrl_L   , f, fullscreenstate, 2 2 toggle"

          "${leaderKey}&Shift_L  , Left, swapwindow, l"
          "${leaderKey}&Shift_L  , Left, moveactive, 300"
          "${leaderKey}&Shift_L  , Up, swapwindow, u"
          "${leaderKey}&Shift_L  , Down, swapwindow, d"
          "${leaderKey}&Shift_L  , Right, swapwindow, r"
          "${leaderKey}&Ctrl_L   , 1, focusmonitor, 0"
          "${leaderKey}&Ctrl_L   , 2, focusmonitor, 1"
        ]
        ++ (
          let
            flatten = lib.lists.flatten;
            map = builtins.map;
            range = map toString (lib.lists.range (1) (9));
            fn = (
              num: [
                "${leaderKey}, ${num}, workspace, r~${num}"
                "${leaderKey}&Shift_L, ${num}, movetoworkspace, r~${num}"
              ]
            );
          in
          flatten (map fn range)
        )
        ++ [
          "${leaderKey}&Ctrl_L&Shift_L, 1, movewindow, mon:0"
          "${leaderKey}&Ctrl_L&Shift_L, 2, movewindow, mon:1"
          "${leaderKey}               , Left, movefocus, l"
          "${leaderKey}               , Down, movefocus, d"
          "${leaderKey}               , Up, movefocus, u"
          "${leaderKey}               , Right, movefocus, r"
          "Shift_L                    , XF86AudioLowerVolume, exec, ${mpc} volume -10"
          "Shift_L                    , XF86AudioNext, exec, ${mpc} next"
          "Shift_L                    , XF86AudioPlay, exec, ${mpc} toggle"
          "Shift_L                    , XF86AudioPrev, exec, ${mpc} prev"
          "Shift_L                    , XF86AudioRaiseVolume, exec, ${mpc} volume +10"
          "Shift_L                    , XF86AudioRaiseVolume, exec, ${mpc} volume +10"
        ];
      };
  };
}
