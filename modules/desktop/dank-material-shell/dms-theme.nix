{ theme }:
{
  id = "electric-blossom";
  name = "Electric Blossom";
  version = "1.0.0";
  author = "jeansidharta";
  description = "High contrast neon theme";
  dark =
    let
      inherit (theme.colors)
        light_gray
        orange
        red
        bg_dark
        green
        blue
        pink
        cyan
        bg_darker
        ;
    in
    {
      primary = cyan;
      primaryText = bg_dark;
      primaryContainer = blue;
      secondary = pink;
      surface = bg_dark;
      surfaceText = pink;
      surfaceVariant = bg_dark;
      surfaceVariantText = light_gray;
      surfaceTint = blue;
      background = bg_darker;
      backgroundText = green;
      outline = light_gray;
      surfaceContainer = bg_dark;
      surfaceContainerHigh = bg_darker;
      error = red;
      warning = orange;
      info = light_gray;
    };
  light = {
  };
  sourceDir = "electric-blossom";
}
