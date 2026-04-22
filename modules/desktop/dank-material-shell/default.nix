{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  is_niri = config.programs.niri.enable;
  is_hyprland = config.programs.hyprland.enable;

  dms = lib.getExe pkgs.dank-material-shell;
  hm-module =
    { theme, config, ... }:
    {
      imports = [
        inputs.dank-material-shell.homeModules.default
      ];

      services.kdeconnect.enable = true;

      # DMS already has a notification system
      services.dunst.enable = lib.mkForce false;
      programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        enableVPN = false;
        enableDynamicTheming = false;
        settings = (builtins.fromJSON (builtins.readFile ./dms-settings.json)) // {
          launcherLogoCustomPath = ../../../assets/nix-snowflake.svg;
          customThemeFile = pkgs.writeText "theme" (
            builtins.toJSON (import ./dms-theme.nix { inherit theme; })
          );
        };
        managePluginSettings = true;
        plugins = {
          dankBatteryAlerts = {
            enable = true;
            src = "${inputs.dms-plugins}/DankBatteryAlerts";
            settings = { };
          };
          wallpaperCarousel = {
            enable = true;
            src = inputs.dms-wallpaper-carousel;
            settings = {
              wallpaperDir = "/home/sidharta/wallpapers/static/";
            };
          };
          volumeMixer = {
            enable = true;
            src = inputs.dms-volume-mixer;
            settings = {
              pillDisplay = "icon";
            };
          };
          dankKDEConnect = {
            enable = true;
            src = "${inputs.dms-plugins}/DankKDEConnect";
            settings = { };
          };
          emojiLauncher = {
            enable = true;
            src = "${inputs.dms-emoji-launcher}";
            settings = { };
          };
          calculator = {
            enable = true;
            src = "${inputs.dms-calculator}";
            settings = { };
          };
          webSearch = {
            enable = true;
            src = "${inputs.dms-web-search}";
            settings = {
              disabledEngines = [
                "duckduckgo"
                "brave"
                "bing"
                "kagi"
                "stackoverflow"
                "ebay"
                "twitter"
                "linkedin"
                "imdb"
                "translate"
                "archlinux"
                "aur"
                "npmjs"
                "pypi"
                "crates"
                "mdn"
              ];
              searchEngines = [
                {
                  id = "mercadolivre";
                  name = "Mercado Livre";
                  icon = "material:cart-shopping";
                  url = "https://lista.mercadolivre.com.br/%s";
                  keywords = [
                    "mercado"
                  ];
                }
              ];
            };
          };
        };
      };
      home.packages = [ pkgs.dank-material-shell ];
      systemd.user =
        let
          wallpaper_dir = "/home/sidharta/wallpapers";
          fselect = lib.getExe pkgs.fselect;
          bash = lib.getExe pkgs.bash;
          jq = lib.getExe pkgs.jq;
        in
        {
          services = {
            wallpaper-timer = {
              Unit = {
                Description = "Change wallpaper at a constant interval";
              };
              Service =
                let
                  get-monitors-hyprland = "${pkgs.hyprland}/bin/hyprctl -j monitors | ${jq} --raw-output '.[].name'";
                  get-monitors-niri = "${pkgs.niri}/bin/niri msg --json outputs | ${jq} --raw-output '.[].name'";
                  get-monitors =
                    if is_hyprland then
                      get-monitors-hyprland
                    else if is_niri then
                      get-monitors-niri
                    else
                      builtins.throw "Unknown compositor used";
                in
                {
                  Type = "oneshot";
                  ExecStart = "${bash} ${(pkgs.writeScript "random-wallpaper" ''
                    IFS=$'\n' read -d ''' -ra files <<< "$(${fselect} "abspath from ${wallpaper_dir} where is_image")"

                    function put_wallpaper {
                      random_index=$((RANDOM % ''${#files[@]}))
                      wallpaper="''${files[$random_index]}"
                      echo "Selecting $wallpaper for output $1"
                      ${dms} ipc call wallpaper setFor "$1" "$wallpaper"
                    }
                    outputs_raw=$(${get-monitors})
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
    };

  binds-module =
    if is_hyprland then
      {
        wayland.windowManager.hyprland.settings.bind =
          let
            leaderKey = "Super_L";
          in
          [
            "${leaderKey}, Space, exec, ${dms} ipc spotlight toggle"
            "${leaderKey}, n, exec, ${dms} ipc notifications toggle"
            "${leaderKey}, v, exec, ${dms} ipc clipboard toggle"
            ", XF86AudioRaiseVolume, exec, ${dms} ipc audio increment 5"
            ", XF86AudioLowerVolume, exec, ${dms} ipc audio decrement 5"
            ", XF86AudioMute, exec, ${dms} ipc audio mute"
            ", XF86AudioNext, exec, ${dms} ipc mpris next"
            ", XF86AudioPlay, exec, ${dms} ipc mpris playPause"
            ", XF86AudioPrev, exec, ${dms} ipc mpris previous"
            "${leaderKey}, s, exec, ${dms} ipc lock lock"
          ];
      }
    else if is_niri then
      {
        programs.niri.settings.binds = {
          "Super+Space".action.spawn = [
            dms
            "ipc"
            "spotlight"
            "toggle"
          ];
          "Super+period".action.spawn = [
            dms
            "ipc"
            "call"
            "wallpaperCarousel"
            "toggle"
          ];
          "Super+n".action.spawn = [
            dms
            "ipc"
            "notifications"
            "toggle"
          ];
          "Super+v".action.spawn = [
            dms
            "ipc"
            "clipboard"
            "toggle"
          ];
          "XF86AudioRaiseVolume".action.spawn = [
            dms
            "ipc"
            "audio"
            "increment"
            "5"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            dms
            "ipc"
            "audio"
            "decrement"
            "5"
          ];
          "XF86AudioMute".action.spawn = [
            dms
            "ipc"
            "audio"
            "mute"
          ];
          "XF86AudioNext".action.spawn = [
            dms
            "ipc"
            "mpris"
            "next"
          ];
          "XF86AudioPlay".action.spawn = [
            dms
            "ipc"
            "mpris"
            "playPause"
          ];
          "XF86AudioPrev".action.spawn = [
            dms
            "ipc"
            "mpris"
            "previous"
          ];
          "Super+s".action.spawn = [
            dms
            "ipc"
            "lock"
            "lock"
          ];
        };
      }
    else
      throw "Unknown compositor used.";

in
{
  imports = [
    inputs.dank-material-shell.outputs.nixosModules.default
  ];
  home-manager.users.sidharta.imports = [
    hm-module
    binds-module
  ];
  nixpkgs.overlays = [
    (config.lib.overlay-helpers.overlay-flake "dank-material-shell")
  ];

  programs.kdeconnect.enable = true;
}
