{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enableXdgAutostart = true;

    settings =
      let
        flameshotExe = "${pkgs.flameshot}/bin/flameshot";
        xclipExe = "${pkgs.xclip}/bin/xclip";
        pamixerExe = "${pkgs.pamixer}/bin/pamixer";
        pactlExe = "${pkgs.pulseaudio}/bin/pactl";
        playerctlExe = "${pkgs.playerctl}/bin/playerctl";
        splatmojiExe = "${pkgs.splatmoji}/bin/splatmoji";
        weztermExe = "${pkgs.wezterm}/bin/wezterm";
        rofiExe = "${pkgs.rofi-wayland-unwrapped}/bin/rofi";
        peekExe = "${pkgs.peek}/bin/peek";
        mpcExe = "${pkgs.mpc-cli}/bin/mpc";
        notifySendExe = "${pkgs.libnotify}/bin/mpc";
      in
      {
        general = {
          layout = "dwindle";
          no_focus_fallback = true;
          resize_on_border = true;
          snap = {
            enabled = true;
          };
        };
        decoration = {
          rounding = 8;
        };
        input = {
          follow_mouse = 2;
        };
        misc = {
          disable_autoreload = true;
          mouse_move_focuses_monitor = false;
          new_window_takes_over_fullscreen = 1;
          exit_window_retains_fullscreen = true;
        };
        dwindle = {
          preserve_split = true;
        };
        bezier = [ "easeInBack, 0.6, -0.28, 0.735, 0.045" ];
        animation = [
          "global, 1, 2, easeInBack"
        ];
        monitor = [
          # General rule so any new monitor is properly placed
          ", preferred, auto, 1"
          "eDP-1, 1366x768, 0x0, 1"
        ];
        input = {
          # Pulled from here:
          # https://github.com/sulmone/X11/blob/master/share/X11/xkb/rules/base.lst
          # kb_model = "pc105";
          # kb_layout = "br";
        };
        bindm = [
          "ALT, mouse:272, movewindow"
          "ALT, mouse:273, resizewindow"
        ];
        bind = [
          ", Print, exec, ${flameshotExe} gui --raw > /tmp/screenshot.png && ${xclipExe} -selection clipboard -t image/png /tmp/screenshot.png; pkill flameshot"
          "Control_L, Print, exec, ${flameshotExe} screen --path \"/home/sidharta/screenshots\" && ${notifySendExe} \"Screenshot saved\""
          ", XF86AudioLowerVolume, exec, ${pamixerExe} -d 3"
          ", XF86AudioMute, exec, ${pactlExe} set-sink-mute @DEFAULT_SINK@ toggle"
          ", XF86AudioNext, exec, ${playerctlExe} next"
          ", XF86AudioPlay, exec, ${playerctlExe} play-pause"
          ", XF86AudioPrev, exec, ${playerctlExe} previous"
          ", XF86AudioRaiseVolume, exec, ${pamixerExe} -i 3"
          "Alt_L, e, exec, ${splatmojiExe} copy"
          "Alt_L&Shift_L, e, exec, ${splatmojiExe} type"
          "Alt_L, F4, killactive, "
          # "Alt_L&Shift_L, F4, forcekillactive, "
          "Alt_L, Return, exec, ${weztermExe}"
          # "Alt_L, comma, exec, ${bspcExe} node --focus any.floating.!focused"
          "Alt_L, f, fullscreen, 1"
          "Alt_L&Shift_L, f, fullscreen, 0"
          # "Alt_L, g, exec, ${toggleBordersExe}"
          # "Alt_L&Shift_L, b, exec, ${bspcExe} node --swap @brother"
          # "Alt_L&Shift_L, comma, exec, ${bspcExe} node --state ~floating"
          # "Alt_L&Shift_L&Ctrl_L, {1,2}, exec, ${bspcExe} node --to-monitor {eDP1,HDMI1} --follow"
          # "Alt_L, p, swapsplit"
          "Alt_L, r, togglesplit, "
          "Alt_L, t, pseudo, "
          "Alt_L&Shift_L, j, moveactive, -300 0"
          "Alt_L&Shift_L, i, moveactive, 0 -300"
          "Alt_L&Shift_L, k, moveactive, 0 300"
          "Alt_L&Shift_L, l, moveactive, 300 0"
          "Alt_L&Shift_L, Left, swapwindow, l"
          "Alt_L&Shift_L, Up, swapwindow, u"
          "Alt_L&Shift_L, Down, swapwindow, d"
          "Alt_L&Shift_L, Right, swapwindow, r"
          "Alt_L, space, exec, ${rofiExe} -show run"
          # Select workspaces
          "Alt_L, 1, workspace, 1"
          "Alt_L, 2, workspace, 2"
          "Alt_L, 3, workspace, 3"
          "Alt_L, 4, workspace, 4"
          "Alt_L, 5, workspace, 5"
          "Alt_L, 6, workspace, 6"
          "Alt_L, 7, workspace, 7"
          "Alt_L, 8, workspace, 8"
          "Alt_L, 9, workspace, 9"
          "Alt_L&Shift_L, 1, movetoworkspace, 1"
          "Alt_L&Shift_L, 2, movetoworkspace, 2"
          "Alt_L&Shift_L, 3, movetoworkspace, 3"
          "Alt_L&Shift_L, 4, movetoworkspace, 4"
          "Alt_L&Shift_L, 5, movetoworkspace, 5"
          "Alt_L&Shift_L, 6, movetoworkspace, 6"
          "Alt_L&Shift_L, 7, movetoworkspace, 7"
          "Alt_L&Shift_L, 8, movetoworkspace, 8"
          "Alt_L&Shift_L, 9, movetoworkspace, 9"
          "Alt_L&Shift_L, 10, movetoworkspace, 10"
          "Alt_L, Left, movefocus, l"
          "Alt_L, Down, movefocus, d"
          "Alt_L, Up, movefocus, u"
          "Alt_L, Right, movefocus, r"
          "Alt_L, equal, splitratio, -0.1"
          "Alt_L, minus, splitratio, +0.1"
          "Alt_L&Shift_L, equal, splitratio, -0.5"
          "Alt_L&Shift_L, minus, splitratio, +0.5"
          "Alt_L, j, moveactive, -10 0"
          "Alt_L, i, moveactive,  0 -10"
          "Alt_L, k, moveactive,  0 10"
          "Alt_L, l, moveactive,  10 0"
          # "Ctrl_L&Shift_L, F1, exec, ${peekExe}"
          "Shift_L, XF86AudioNext, exec, ${mpcExe} next"
          "Shift_L, XF86AudioPlay, exec, ${mpcExe} toggle"
          "Shift_L, XF86AudioPrev, exec, ${mpcExe} prev"
        ];
      };
  };
}
