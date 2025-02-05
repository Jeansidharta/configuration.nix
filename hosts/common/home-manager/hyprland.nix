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
        mpcExe = "${pkgs.mpc-cli}/bin/mpc";
        notifySendExe = "${pkgs.libnotify}/bin/notify-send";
        zsh = "${pkgs.zsh}/bin/zsh";
        yazi = "${pkgs.yazi}/bin/yazi";

        leaderKey = "Super_L";
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
          # Pulled from here:
          # https://github.com/sulmone/X11/blob/master/share/X11/xkb/rules/base.lst
          # kb_model = "pc105";
          kb_layout = "us";
          kb_variant = "alt-intl";
          # kb_options = "grp:caps_toggle";
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
        windowrulev2 = [
          "float, class:waypaper"
          "size 600 600, class:waypaper"
        ];
        bindm = [
          "${leaderKey}, mouse:272, movewindow"
          "${leaderKey}, mouse:273, resizewindow"
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
          "${leaderKey}, v, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
          "${leaderKey}, e, exec, ${splatmojiExe} copy"
          "${leaderKey}, x, togglefloating"
          "${leaderKey}&Shift_L, e, exec, ${splatmojiExe} type"
          "${leaderKey}, F4, killactive, "
          # "${leaderKey}&Shift_L, F4, signal, 9"
          "${leaderKey}, Return, exec, ${weztermExe} start ${zsh} -c ${yazi}"
          "${leaderKey}&Shift_L, Return, exec, ${weztermExe}"
          "${leaderKey}, f, fullscreen, 1"
          "${leaderKey}&Shift_L, f, fullscreen, 0"
          # "${leaderKey}, g, exec, ${toggleBordersExe}"
          # "${leaderKey}&Shift_L&Ctrl_L, {1,2}, exec, ${bspcExe} node --to-monitor {eDP1,HDMI1} --follow"
          "${leaderKey}, r, togglesplit, "
          "${leaderKey}, t, pseudo, "
          "${leaderKey}&Shift_L, j, moveactive, -300 0"
          "${leaderKey}&Shift_L, i, moveactive, 0 -300"
          "${leaderKey}&Shift_L, k, moveactive, 0 300"
          "${leaderKey}&Shift_L, l, moveactive, 300 0"
          "${leaderKey}&Shift_L, Left, swapwindow, l"
          "${leaderKey}&Shift_L, Up, swapwindow, u"
          "${leaderKey}&Shift_L, Down, swapwindow, d"
          "${leaderKey}&Shift_L, Right, swapwindow, r"
          "${leaderKey}, space, exec, ${rofiExe} -show run"
          # Select workspaces
          "${leaderKey}, 1, workspace, 1"
          "${leaderKey}, 2, workspace, 2"
          "${leaderKey}, 3, workspace, 3"
          "${leaderKey}, 4, workspace, 4"
          "${leaderKey}, 5, workspace, 5"
          "${leaderKey}, 6, workspace, 6"
          "${leaderKey}, 7, workspace, 7"
          "${leaderKey}, 8, workspace, 8"
          "${leaderKey}, 9, workspace, 9"
          "${leaderKey}&Shift_L, 1, movetoworkspace, 1"
          "${leaderKey}&Shift_L, 2, movetoworkspace, 2"
          "${leaderKey}&Shift_L, 3, movetoworkspace, 3"
          "${leaderKey}&Shift_L, 4, movetoworkspace, 4"
          "${leaderKey}&Shift_L, 5, movetoworkspace, 5"
          "${leaderKey}&Shift_L, 6, movetoworkspace, 6"
          "${leaderKey}&Shift_L, 7, movetoworkspace, 7"
          "${leaderKey}&Shift_L, 8, movetoworkspace, 8"
          "${leaderKey}&Shift_L, 9, movetoworkspace, 9"
          "${leaderKey}, Left, movefocus, l"
          "${leaderKey}, Down, movefocus, d"
          "${leaderKey}, Up, movefocus, u"
          "${leaderKey}, Right, movefocus, r"
          "${leaderKey}, equal, splitratio, -0.1"
          "${leaderKey}, minus, splitratio, +0.1"
          "${leaderKey}&Shift_L, equal, splitratio, -0.5"
          "${leaderKey}&Shift_L, minus, splitratio, +0.5"
          "${leaderKey}, j, moveactive, -10 0"
          "${leaderKey}, i, moveactive,  0 -10"
          "${leaderKey}, k, moveactive,  0 10"
          "${leaderKey}, l, moveactive,  10 0"
          "Shift_L, XF86AudioNext, exec, ${mpcExe} next"
          "Shift_L, XF86AudioPlay, exec, ${mpcExe} toggle"
          "Shift_L, XF86AudioPrev, exec, ${mpcExe} prev"
        ];
      };
  };
}
