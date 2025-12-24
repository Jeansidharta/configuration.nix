{
  outputs =
    { ... }:
    let
      colors = rec {
        bg_darker = "#0D0C1E"; # 080814
        bg_dark = "#1b1a33";
        bg_medium_dark = "#28274d";
        bg_medium = "#434180";
        bg_medium_light = "#504e99";
        bg_medium_lighter = "#6b68cc";
        bg_light = "#7975e6";
        bg_lighter = "#8682ff";

        light_yellow = "#d7a65f";
        blue = "#0026e6";
        light_blue = "#0060e6";
        light_purple = "#9933ff";
        purple = "#8c33ff";
        orange = "#e68600";
        cyan = "#00dee6";
        light_cyan = "#00e6b8";
        green = "#12de00";
        pink = "#ea00d9";
        gray = "#4A5057";

        tomato_red = "#f44336";
        dark_pink = "#b300a7";
        dark_green = "#66bb6a";

        error = tomato_red;
        success = dark_green;

        primary_color = pink;
        secondary_color = orange;
        tertiary_color = cyan;
        quaternary_color = green;
        quintenary_color = purple;
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
              foreground = colors.bg_light;
              cursor_fg = colors.bg_lighter;
              background = colors.bg_darker;
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
                colors.bg_medium_dark # 1
                colors.light_purple # 2
                colors.dark_green # 3
                colors.light_yellow # 4
                colors.light_blue # 5
                colors.dark_pink # 6
                colors.light_cyan # 7
                colors.gray # 8
              ];
              brights = [
                colors.gray # 1
                colors.purple # 2
                colors.green # 3
                colors.orange # 4
                colors.blue # 5
                colors.pink # 6
                colors.cyan # 7
                colors.gray # 8
              ];
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
