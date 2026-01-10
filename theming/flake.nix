{
  outputs =
    { ... }:
    let
      colors = rec {
        bg_darker = "#00001a";
        bg_dark = "#0d0d1a";
        bg_light = "#ccfff7";
        bg_lighter = "#e6fffa";

        light_gray = "#bfbfbf";
        gray = "#333366";
        dark_gray = "#202040";
        red = "#ff0055";
        green = "#15ff00";
        orange = "#ff8000";
        blue = "#0061ff";
        pink = "#ff66cc";
        cyan = "#00ffd5";
        white = "#ffffff";

        black = "#0d0d1a";
        dark_red = "#d90048";
        dark_green = "#10bf00";
        dark_yellow = "#bf6000";
        dark_blue = "#0049bf";
        dark_pink = "#bf4d99";
        dark_cyan = "#00bf9f";

        error = red;
        success = green;

        primary_color = pink;
        secondary_color = orange;
        tertiary_color = cyan;
        quaternary_color = green;
        quintenary_color = dark_pink;
        base_text = bg_lighter;
        disabled = gray;
      };
      colorsWithoutHash = builtins.mapAttrs (
        _: val: builtins.substring 1 ((builtins.stringLength val) - 1) val
      ) colors;
      theme = {
        colors = colors;
        colorsWithoutHash = colorsWithoutHash;
      };
    in
    {
      theme = theme;
      home-manager-module =
        { options, lib, ... }:
        lib.mkMerge [
          {
            programs.wezterm.colorSchemes.mainTheme = {
              # Color order ANSI:
              # black
              # maroon
              # green
              # olive
              # navy
              # purple
              # teal
              # silver
              # Color Order Brights
              # grey
              # red
              # lime
              # yellow
              # blue
              # fuchsia
              # aqua
              # white
              ansi = [
                colors.black # 1
                colors.dark_red # 2
                colors.dark_green # 3
                colors.dark_yellow # 4
                colors.dark_blue # 5
                colors.dark_pink # 6
                colors.dark_cyan # 7
                colors.light_gray # 8
              ];
              brights = [
                colors.gray # 1
                colors.red # 2
                colors.green # 3
                colors.orange # 4
                colors.blue # 5
                colors.pink # 6
                colors.cyan # 7
                colors.white # 8
              ];

              foreground = colors.bg_light;
              cursor_fg = colors.bg_lighter;
              background = colors.bg_darker;
            };
            xsession.windowManager.bspwm.settings = {
              normal_border_color = colors.bg_light;
              active_border_color = colors.secondary_color;
              focused_border_color = colors.primary_color;
              presel_feedback_color = colors.gray;
            };

            programs.tmux.extraConfig = ''
              # clock mode
              setw -g clock-mode-colour yellow

              # copy mode
              setw -g mode-style 'fg=black bg=green bold'

              # panes
              set -g pane-border-style 'fg=black'
              set -g pane-active-border-style 'fg=yellow'

              # statusbar
              set -g status-position bottom
              set -g status-justify left
              set -g status-style 'fg=green'

              set -g status-left '''
              set -g status-left-length 10

              set -g status-right-style 'fg=black bg=yellow'

              setw -g window-status-current-style 'fg=green bg=black'
              setw -g window-status-style 'fg=green bg=black'
              setw -g window-status-format ' #I #[fg=white]#W #[fg=yellow]#F '

              setw -g window-status-bell-style 'fg=black bg=green bold'

              # messages
              set -g message-style 'fg=green bg=black bold'
              set -g message-command-style 'fg=black bg=green bold'
            '';
          }
          (lib.optionalAttrs (options ? programs.ewwCustom) {
            programs.ewwCustom = {
              extraVariables = {
                inherit (colors)
                  primary_color
                  secondary_color
                  tertiary_color
                  quaternary_color
                  quintenary_color
                  base_text
                  disabled
                  error
                  success
                  ;
              };
              extraFiles."colors.scss" = ''
                $color-fg: ${colors.bg_light};
                $color-pink: ${colors.pink};
                $color-red: ${colors.error};
                $color-error: ${colors.error};
                $color-success: ${colors.success};
                $color-orange: ${colors.orange};
                $color-orange-thin: ${colors.orange};
                $color-teal: ${colors.cyan};
                $color-green: ${colors.green};
                $color-blue: ${colors.blue};
                $color-purple: ${colors.purple};
                $color-grey: ${colors.gray};

                $color-base: ${colors.bg_lighter};
                $color-background: ${colors.bg_dark};
                $color-background-solid: ${colors.bg_dark};
              '';
            };
          })
        ];
    };
}
