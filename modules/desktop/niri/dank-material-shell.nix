{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  dms = lib.getExe pkgs.dank-material-shell;
  hm-module = {
    imports = [
      inputs.dank-material-shell.homeModules.default
    ];
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      enableVPN = false;
      enableDynamicTheming = false;
      settings = (import ./dms-settings.nix) { inherit pkgs; };
    };
    home.packages = [ pkgs.dank-material-shell ];
    systemd.user =
      let
        wallpaper_dir = "/home/sidharta/wallpapers";
        fselect = lib.getExe pkgs.fselect;
        bash = lib.getExe pkgs.bash;
        jq = lib.getExe pkgs.jq;
        niri = lib.getExe pkgs.niri-unstable;
      in
      {
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
                  ${dms} ipc call wallpaper setFor "$1" "$wallpaper"
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
    programs.niri.settings.binds = {
      "Super+Space".action.spawn = [
        dms
        "ipc"
        "call"
        "spotlight"
        "toggle"
      ];
      "Super+v".action.spawn = [
        dms
        "ipc"
        "call"
        "clipboard"
        "toggle"
      ];
      "XF86AudioRaiseVolume".action.spawn = [
        dms
        "ipc"
        "call"
        "audio"
        "increment"
        "5"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        dms
        "ipc"
        "call"
        "audio"
        "decrement"
        "5"
      ];
      "XF86AudioMute".action.spawn = [
        dms
        "ipc"
        "call"
        "audio"
        "mute"
      ];
      "XF86AudioNext".action.spawn = [
        dms
        "ipc"
        "call"
        "mpris"
        "next"
      ];
      "XF86AudioPlay".action.spawn = [
        dms
        "ipc"
        "call"
        "mpris"
        "playPause"
      ];
      "XF86AudioPrev".action.spawn = [
        dms
        "ipc"
        "call"
        "mpris"
        "previous"
      ];
      "Super+s".action.spawn = [
        dms
        "ipc"
        "call"
        "lock"
        "lock"
      ];
    };
  };
in
{
  imports = [
    inputs.dank-material-shell.outputs.nixosModules.default
  ];
  home-manager.users.sidharta.imports = [ hm-module ];
  services.power-profiles-daemon.enable = true;
  services.upower = {
    enable = true;
  };
  nixpkgs.overlays = [
    (config.lib.overlay-helpers.overlay-flake "dank-material-shell")
  ];
}
