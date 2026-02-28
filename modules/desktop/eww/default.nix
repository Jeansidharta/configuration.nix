{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  hm-module = {
    imports = [
      inputs.custom-eww.outputs.homeManagerModule
      inputs.walker.outputs.homeManagerModules.default
    ];

    home.packages = [
      pkgs.walker # Application launcher
    ];

    programs.ewwCustom = {
      extraVariables = {
        topBarMonitor = lib.mkDefault "0";
      };
    };

    programs.walker = {
      enable = true;
      runAsService = true;
    };

    programs.niri.settings.binds =
      let
        walker = lib.getExe pkgs.walker;
        cliphist = lib.getExe pkgs.cliphist;
        wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
        pamixer = lib.getExe pkgs.pamixer;
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        playerctl = lib.getExe pkgs.playerctl;
      in
      {
        "Super+Space".action.spawn = [ walker ];
        "Super+v".action.spawn-sh =
          "${cliphist} list | ${walker} -d -l 2 | ${cliphist} decode | ${wl-copy}";
        "XF86AudioRaiseVolume".action.spawn = [
          pamixer
          "-i"
          "3"
        ];
        "XF86AudioLowerVolume".action.spawn = [
          pamixer
          "-d"
          "3"
        ];
        "XF86AudioMute".action.spawn = [
          pactl
          "set-sink-mute"
          "@DEFAULT_SINK@"
          "toggle"
        ];
        "XF86AudioNext".action.spawn = [
          playerctl
          "next"
        ];
        "XF86AudioPlay".action.spawn = [
          playerctl
          "play-pause"
        ];
        "XF86AudioPrev".action.spawn = [
          playerctl
          "previous"
        ];
      };

    programs.ewwCustom = {
      enable = true;
      systemdService = true;
      systemdTarget = "graphical-session.target";
      startingOpenWindow = "top_bar";
    };

    programs.elephant = {
      enable = true;
      installService = true;
      providers = [
        "desktopapplications"
        "files"
        "clipboard"
        "runner"
        "symbols"
        "calc"
        "menus"
        "providerlist"
        "websearch"
        # "todo"
        "unicode"
        # "windows"
      ];
      settings = {
        providers = {
        };
      };
    };

    xdg.configFile."elephant/clipboard.toml".source =
      (pkgs.formats.toml { }).generate "elephant/clipboard.toml"
        (
          let
            wezterm = lib.getExe pkgs.wezterm;
            neovim = lib.getExe pkgs.neovim;
            vipe = "${pkgs.moreutils}/bin/vipe";
            wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
          in
          {
            text_editor_cmd = ''
              ${wezterm} start --class wezterm.clipboard -- bash -c "export EDITOR=${neovim} ; cat %FILE% | ${vipe} | ${wl-copy} && exit"
            '';
          }
        );
    xdg.configFile."elephant/websearch.toml".source =
      (pkgs.formats.toml { }).generate "elephant/websearch.toml"
        {
          entries = [
            {
              default = true;
              name = "Google";
              url = "https://www.google.com/search?q=%TERM%";
            }
          ];
        };

    services.swww.enable = true;

    systemd.user =
      let
        wallpaper_dir = "/home/sidharta/wallpapers";
        fselect = lib.getExe pkgs.fselect;
        swww = lib.getExe pkgs.swww;
        bash = lib.getExe pkgs.bash;
        jq = lib.getExe pkgs.jq;
        niri = lib.getExe pkgs.niri-unstable;
      in
      {
        # Make sure eww starts after the niri compositor.
        eww.Unit.After = [ "niri.service" ];

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

  };

  inherit (config.lib.overlay-helpers) overlay-flake;
in
{
  home-manager.users.sidharta.imports = [ hm-module ];
  nixpkgs.overlays = [
    inputs.swww.overlays.default
    (overlay-flake "walker")
  ];
}
