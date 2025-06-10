{ pkgs, ... }:
let
  wallpaper_dir = "/home/sidharta/wallpapers";
  fselect = "${pkgs.fselect}/bin/fselect";
  swww = "${pkgs.swww}/bin/swww";
  bash = "${pkgs.bash}/bin/bash";
  jq = "${pkgs.jq}/bin/jq";
in
{
  programs.waypaper = {
    enable = true;
    settings = {
      folder = wallpaper_dir;
      all_subfolders = true;
      subfolders = true;
      sort = "random";
    };
  };
  systemd.user = {
    services = {
      wallpaper-timer = {
        Unit = {
          Description = "Change wallpaper in a constant interval";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${bash} ${(pkgs.writeScript "random-wallpaper" ''
            IFS=$'\n' read -d ''' -ra files <<< "$(${fselect} "abspath from ${wallpaper_dir} where is_image")"

            function put_wallpaper {
              random_index=$((RANDOM % ''${#files[@]}))
              wallpaper="''${files[$random_index]}"
              echo "Selecting $wallpaper for output $1"
              ${swww} img --outputs "$1" "$wallpaper" 
            }
            outputs_raw=$(hyprctl monitors -j | jq ".[].name")
            IFS=$'\n' read -d ''' -ra outputs <<< "$outputs_raw"
            for output in "''${outputs[@]}"; do
              trim_start=''${output#\"}
              trim_end=''${trim_start%\"}
              put_wallpaper "$trim_end"
            done
          '')}";
        };
      };
    };
    timers = {
      wallpaper-timer = {
        Unit = {
          Description = "Change wallpaper in a constant interval";
        };
        Timer = {
          Persistent = true;
          OnBootSec = "15 min";
          OnUnitActiveSec = "15 min";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };

}
