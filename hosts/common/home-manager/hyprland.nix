{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enableXdgAutostart = true;

    settings =
      let
        hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
        jq = "${pkgs.jq}/bin/jq";
        hyprctl = "${pkgs.hyprland}/bin/hyprctl";
        pamixer = "${pkgs.pamixer}/bin/pamixer";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        splatmoji = "${pkgs.splatmoji}/bin/splatmoji";
        wezterm = "${pkgs.wezterm}/bin/wezterm";
        rofi = "${pkgs.rofi-wayland-unwrapped}/bin/rofi";
        mpc = "${pkgs.mpc}/bin/mpc";
        uwsm = "${pkgs.uwsm}/bin/uwsm";
        # notifySend = "${pkgs.libnotify}/bin/notify-send";
        zsh = "${pkgs.zsh}/bin/zsh";
        yazi = "${pkgs.yazi}/bin/yazi";
        vipe = "${pkgs.moreutils}/bin/vipe";
        cliphist = "${pkgs.cliphist}/bin/cliphist";
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
        neovim = "${pkgs.mypkgs.neovim}/bin/nvim";
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
        updateSongTags = (
          let
            tmsu = "${pkgs.tmsu}/bin/tmsu";
          in
          pkgs.writeScript "updateSongTags" ''
            music_dir="/home/sidharta/music"
            database="$music_dir/.tmsu/db"
            filename=$(${mpc} current -f %file%)
            filepath="$music_dir/$filename"
            tags=$(${tmsu} --database "$database" tags --name never "$filepath")
            ${wezterm} start --always-new-process -- bash -c "
              newtags=\$(${vipe} --suffix=\"$filename\" <<< \"$tags\")
              ${tmsu} --database \"$database\" untag --all \"$filepath\"
              ${tmsu} --database \"$database\" tag \"$filepath\" \$newtags
            "
          ''
        );

        modifyClipboard = pkgs.writeScript "write-script" ''
          ${wezterm} start -- bash -c "export EDITOR=${neovim} ; ${wl-paste} | ${vipe} | ${wl-copy} && exit"
        '';
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
          kb_variant = "intl";
          # kb_options = "grp:caps_toggle";
        };
        device = {
          name = "clover-virtual-keyboard";
          kb_layout = "us";
          kb_variant = "";
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
          "HDMI-A-1, preferred, 0x0, 1"
          "HDMI-A-2, preferred, 1920x700, 1, transform, 1"
        ];
        windowrule = [
          "size 600 600, class:waypaper"
          "move 50%-300 100%-600, class:waypaper"
          "pin, class:waypaper"
          "float, class:waypaper"
          "opacity 0.8, class:waypaper"

          # Smart Gaps
          "bordersize 0, floating:0, onworkspace:w[tv1]s[false]"
          "rounding 0, floating:0, onworkspace:w[tv1]s[false]"
          "bordersize 0, floating:0, onworkspace:f[1]s[false]"
          "rounding 0, floating:0, onworkspace:f[1]s[false]"
        ];
        bindm = [
          "${leaderKey}, mouse:272, movewindow"
          "${leaderKey}, mouse:273, resizewindow"
        ];
        workspace = [
          # Smart Gaps
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
        bind =
          [
            ", Print, exec, ${hyprshot} --mode region --clipboard-only"
            "Control_L, Print, exec, ${hyprshot} --mode active --mode output --clipboard-only"
            ", XF86AudioLowerVolume, exec, ${pamixer} -d 3"
            ", XF86AudioMute, exec, ${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
            ", XF86AudioNext, exec, ${playerctl} next"
            ", XF86AudioPlay, exec, ${playerctl} play-pause"
            ", XF86AudioPrev, exec, ${playerctl} previous"
            ", XF86AudioRaiseVolume, exec, ${pamixer} -i 3"
            "${leaderKey}, v, exec, ${cliphist} list | ${rofi} -dmenu | ${cliphist} decode | ${wl-copy}"
            "${leaderKey}&Control_L, v, exec, ${modifyClipboard}"
            "${leaderKey}&Shift_L, v, exec, ${paste-qrcode}"
            "${leaderKey}, e, exec, ${splatmoji} copy"
            "${leaderKey}, x, togglefloating"
            "${leaderKey}&Shift_L, e, exec, ${splatmoji} type"
            "${leaderKey}, F4, killactive, "
            "${leaderKey}&Shift_L, F4, forcekillactive, "
            "${leaderKey}, Return, exec, ${uwsm} app -- ${wezterm}"
            "${leaderKey}&Shift_L, Return, exec, ${uwsm} app -- ${wezterm} start ${zsh} -c ${yazi}"
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
            "${leaderKey}, space, exec, ${uwsm} app -- ${rofi} -show run"
            # Select workspaces
            "${leaderKey}&Ctrl_L, 1, focusmonitor, 0"
            "${leaderKey}&Ctrl_L, 2, focusmonitor, 1"
          ]
          ++ (
            let
              flatten = pkgs.lib.lists.flatten;
              map = builtins.map;
              range = map toString (pkgs.lib.lists.range (1) (9));
              fn = (
                num: [
                  # "${leaderKey}, ${num}, execr, ${hyprctl} dispatch workspace r~${num} && ${hyprctl} activeworkspace -j | ${jq} .id | ${xargs} -I '{}' ${hyprctl} dispatch renameworkspace '{} ${num}'"
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
            "Shift_L, XF86AudioLowerVolume, exec, ${mpc} volume -10"
            "Shift_L, XF86AudioNext, exec, ${mpc} next"
            "Shift_L, XF86AudioPlay, exec, ${mpc} toggle"
            "Shift_L, XF86AudioPrev, exec, ${mpc} prev"
            "Shift_L, XF86AudioRaiseVolume, exec, ${mpc} volume +10"
            "Shift_L, XF86AudioRaiseVolume, exec, ${mpc} volume +10"
            ", XF86Tools, exec, ${updateSongTags}"
          ];
      };
  };
}
