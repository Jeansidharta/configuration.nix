{ ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      animations = {
        enabled = true;
        bezier = "linear, 1, 1, 0, 0";
        animation = [
          "fadeIn, 1, 5, linear"
          "fadeOut, 1, 5, linear"
        ];
      };

      label = [
        {
          text = "cmd[update:1000] echo $(date +%T)";
          color = "rgba(200, 200, 200, 1.0)";

          shadow_passes = 1;
          position = "0, -30";
          halign = "center";
          valign = "center";
        }
        {
          text = "cmd[update:1000] echo $(date +%F) $(date +%A)";
          color = "rgba(200, 200, 200, 1.0)";

          shadow_passes = 1;
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = {
        monitor = "";
        fade_on_empty = false;
        size = "400, 30";
        shadow_passes = 1;
        position = "0, -100";
      };

      background = {
        path = "${./lockscreen.png}";
        blur_passes = 2;
      };
    };
  };
}
