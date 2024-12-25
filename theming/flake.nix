{
  outputs =
    { ... }:
    let
      colors = rec {
        bgDarker = "0D0C1E"; # 080814
        bgDark = "1b1a33";
        bgMediumDark = "28274d";
        bgMedium = "434180";
        bgMediumLight = "504e99";
        bgMediumLighter = "6b68cc";
        bgLight = "7975e6";
        bgLighter = "8682ff";

        lightYellow = "d7a65f";
        blue = "0060e6";
        purple = "8c33ff";
        orange = "e68600";
        cyan = "00dee6";
        green = "12de00";
        pink = "ea00d9";
        gray = "4A5057";

        error = "f44336";
        success = "66bb6a";

        primaryColor = pink;
        secondaryColor = orange;
        tertiaryColor = cyan;
        quaternaryColor = green;
        quintenaryColor = purple;
        baseText = bgLighter;
        disabled = gray;
      };
      colorsWithHash = builtins.mapAttrs (_: val: "#${val}") colors;
      theme = {
        colors = colors;
        colorsWithHash = colorsWithHash;
      };
    in
    {
      theme = theme;
      home-manager-module = {
        programs.wezterm.colorSchemes.mainTheme = with colorsWithHash; rec {
          foreground = bgLight;
          cursor_fg = bgLighter;
          background = bgDarker;
          ansi = [
            gray
            lightYellow
            pink
            orange
            blue
            green
            cyan
            gray
          ];
          brights = ansi;
        };

        xsession.windowManager.bspwm.settings = with colorsWithHash; {
          normal_border_color = bgLight;
          active_border_color = secondaryColor;
          focused_border_color = primaryColor;
          presel_feedback_color = gray;
        };

        programs.ewwCustom = rec {
          extraVariables = with colorsWithHash; {
            inherit
              primaryColor
              secondaryColor
              tertiaryColor
              quaternaryColor
              quintenaryColor
              baseText
              disabled
              error
              success
              ;
          };
          extraFiles."colors.scss" =
            with extraVariables;
            with colorsWithHash;
            ''
              $color-fg: ${bgLight};
              $color-pink: ${pink};
              $color-red: ${error};
              $color-error: ${error};
              $color-success: ${success};
              $color-orange: ${orange};
              $color-orange-thin: ${orange};
              $color-teal: ${cyan};
              $color-green: ${green};
              $color-blue: ${blue};
              $color-purple: ${purple};
              $color-grey: ${gray};

              $color-base: ${bgLighter};
              $color-background: ${bgDark};
              $color-background-solid: ${bgDark};
            '';
        };
      };
    };
}
