{ pkgs, ... }:
let
  toggle-fullscreen-monocle = pkgs.writeShellApplication {
    name = "toggle-fullscreen-monocle";
    runtimeInputs = with pkgs; [
      bspwm
      eww
    ];
    text = builtins.readFile ./toggle-fullscreen-monocle.sh;
  };
  toggle-borders = pkgs.writeShellApplication {
    name = "toggle-borders";
    runtimeInputs = with pkgs; [
      bspwm
      eww
    ];
    text = builtins.readFile ./toggle-borders.sh;
  };
  focus-monocle-aware = pkgs.writeShellApplication {
    name = "focus-monocle-aware";
    runtimeInputs = with pkgs; [ bspwm ];
    text = builtins.readFile ./focus-monocle-aware.sh;
  };
in
{
  enable = true;
  keybindings =
    with pkgs;
    let
      flameshotExe = "${flameshot}/bin/flameshot";
      xclipExe = "${xclip}/bin/xclip";
      pamixerExe = "${pamixer}/bin/pamixer";
      pactlExe = "${pulseaudio}/bin/pactl";
      playerctlExe = "${playerctl}/bin/playerctl";
      splatmojiExe = "${splatmoji}/bin/splatmoji";
      bspcExe = "${bspwm}/bin/bspc";
      ghosttyExe = "${ghostty}/bin/ghostty";
      rofiExe = "${rofi-unwrapped}/bin/rofi";
      peekExe = "${peek}/bin/peek";
      mpcExe = "${mpc-cli}/bin/mpc";
      notifySendExe = "${libnotify}/bin/mpc";
      toggleFullscreenMonocleExe = "${toggle-fullscreen-monocle}/bin/toggle-fullscreen-monocle";
      toggleBordersExe = "${toggle-borders}/bin/toggle-borders";
      focusMonocleAwareExe = "${focus-monocle-aware}/bin/focus-monocle-aware";
    in
    {
      "Print" =
        "${flameshotExe} gui --raw > /tmp/screenshot.png && ${xclipExe} -selection clipboard -t image/png /tmp/screenshot.png; pkill flameshot";
      "XF86AudioLowerVolume" = "${pamixerExe} -d 3";
      "XF86AudioMute" = "${pactlExe} set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioNext" = "${playerctlExe} next";
      "XF86AudioPlay;" = "${playerctlExe} play-pause";
      "XF86AudioPrev" = "${playerctlExe} previous";
      "XF86AudioRaiseVolume" = "${pamixerExe} -i 3";
      "alt + e" = "${splatmojiExe} copy";
      "alt + shift + e" = "${splatmojiExe} type";
      "alt + F4" = "${bspcExe} node --close";
      "alt + Return" = "${ghosttyExe}";
      "alt + b" = "${bspcExe} node --focus @brother";
      "alt + bracketleft" = "${bspcExe} node @parent --balance";
      "alt + comma" = "${bspcExe} node --focus any.floating.!focused";
      "alt + control + Escape" = "kill -s USR1 $(pidof deadd-notification-center)";
      "alt + control + {1,2}" = "${bspcExe} monitor --focus {eDP1,HDMI1}";
      "alt + ctrl + {Left,Up,Down,Right}" = "${bspcExe} node --presel-dir ~{west,north,south,east}";
      "alt + f" = "${toggleFullscreenMonocleExe} monocle";
      "alt + g" = "${toggleBordersExe}";
      "alt + p" = "${bspcExe} node --focus @parent";
      "alt + q" = "${bspcExe} node --to-node last.!automatic";
      "alt + r" = "${bspcExe} node @parent --rotate 90";
      "alt + shift + F4" = "${bspcExe} node --kill";
      "alt + shift + b" = "${bspcExe} node --swap @brother";
      "alt + shift + comma" = "${bspcExe} node --state ~floating";
      "alt + shift + control + {1,2}" = "${bspcExe} node --to-monitor {eDP1,HDMI1} --follow";
      "alt + shift + f" = "${bspcExe} node --state \\~fullscreen";
      "alt + shift + p" = "${bspcExe} node --swap @parent/brother";
      "alt + shift + r" = "${bspcExe} node @parent --rotate 270";
      "alt + shift + t" = "${bspcExe} node --state ~pseudo_tiled";
      "alt + shift + {1-9,0}" = "${bspcExe} node --to-desktop '{1-9,10}.local' --follow";
      "alt + shift + {Left,Down,Up,Right}" = "${bspcExe} node --swap {west,south,north,east}.local";
      "alt + shift + {j, i, k, l}" = "${bspcExe} node -v {-300 0, 0 -300, 0 300, 300 0 }";
      "alt + space" = "${rofiExe} -show run";
      "alt + t" = "${bspcExe} node --state tiled";
      "alt + {1-9,0}" = "${bspcExe} desktop --focus '{1-9,10}.local'";
      "alt + {Left,Down,Up,Right}" = "${focusMonocleAwareExe} {west,south,north,east}.local";
      "alt + {_,shift +} equal" = "${bspcExe} node @parent --ratio -{5,0.1}";
      "alt + {_,shift +} minus" = "${bspcExe} node @parent --ratio +{5,0.1}";
      "alt + {j, i, k, l}" = "${bspcExe} node -v {-10 0, 0 -10, 0 10, 10 0 }";
      "ctrl + Print" =
        "${flameshotExe} screen --path \"/home/sidharta/screenshots\" && ${notifySendExe} \"Screenshot saved\"";
      "ctrl + shift + F1" = "${peekExe}";
      "shift + XF86AudioNext" = "${mpcExe} next";
      "shift + XF86AudioPlay" = "${mpcExe} toggle";
      "shift + XF86AudioPrev" = "${mpcExe} prev";
    };
}
