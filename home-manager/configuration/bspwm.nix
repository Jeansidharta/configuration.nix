{ config, pkgs, ... }:
{
  enable = true;
  settings = {
    # normal_border_color = "#ff0f9b";
    # focused_border_color = "#9b0fff";
    # presel_feedback_color = "#ff0000";

    border_width = 3;
    window_gap = 30;
    top_padding = 0;

    split_ratio = 0.5;
    borderless_monocle = true;
    gapless_monocle = true;
    swallow_first_click = false;
    single_monocle = false;
  };
  extraConfig = ''
    bspc monitor --reset-desktops 1 2 3 4 5 6 7 8 9
    bspc rule --add "Peek" state=floating
    bspc rule --add "*:*:Eww - wifi" border=off
    bspc rule --add "*:*:Eww - launcher" border=off
  '';
}
