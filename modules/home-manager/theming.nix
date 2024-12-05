{ pkgs, ... }:
with pkgs.theme;
{
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
}
