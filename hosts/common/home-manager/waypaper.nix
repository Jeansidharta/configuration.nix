{ pkgs, lib, ... }:
let
  wallpaper_dir = "/home/sidharta/wallpapers";
  fselect = lib.getExe pkgs.fselect;
  swww = lib.getExe pkgs.swww;
  bash = lib.getExe pkgs.bash;
  jq = lib.getExe pkgs.jq;
  niri = lib.getExe pkgs.niri-unstable;
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
          Description = "Change wallpaper at a constant interval";
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
            outputs_raw=$(${niri} msg --json outputs | ${jq} --raw-output ".[].name")
            IFS=$'\n' read -d ''' -ra outputs <<< "$outputs_raw"
            for output in "''${outputs[@]}"; do
              put_wallpaper "$output"
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
