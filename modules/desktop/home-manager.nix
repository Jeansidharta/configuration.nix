{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard # Clipboard software
    sxiv # Simple image viewer
    libnotify # Send d-bus notification through the terminal
    walker # Application launcher
    helvum # Manipulate Pipewire connections
    qpwgraph # Manipulate Pipewire connections
    dragon-drop # Allows to drag and drop
    wiremix # TUI for configuring pipewire audio

    mpc # cli to controll the mpd daemon
    drawy # App to draw, similar do excalidraw
    syncplay

    kitty # Backup terminal in case ghostty dies
    wireshark

    # === Non free ===
    discord
    telegram-desktop

    # === Fonts ===
    jetbrains-mono
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
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
      "bluetooth"
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

  programs.satty = {
    enable = true;
    settings = {
      general = {
        initial-tool = "brush";
        output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
        save-after-copy = true;
      };
    };
  };

  programs.ewwCustom = {
    enable = true;
    systemdService = true;
    systemdTarget = "graphical-session.target";
    startingOpenWindow = "top_bar";
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      name = "default";
      id = 0;
      settings = {
      };
    };
  };
  programs.mpv = {
    enable = true;
    config = {
      ytdl-raw-options = "extractor-args=\"youtube:player-client=default,-tv_simply\"";
    };
  };

  programs.zk = {
    enable = true;
    settings = {
      notebook = {
        dir = "~/notes";
      };
    };
  };

  services.dunst.enable = true;
  services.udiskie.enable = true;

  services.cliphist = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
  };

  services.swww.enable = true;

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };

  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      show_startup_tips = false;
      copy_command = "wl-copy";
    };
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/sidharta/music";
    extraConfig = ''
            audio_output {
              type            "pipewire"
              name            "PipeWire Sound Server"
            }

            audio_output {
              type            "fifo"
              name            "snapcast fifo"
              path 			"/home/sidharta/docker-wireguard/snapcast/volume/snapfifo"
      		format          "48000:16:2"
      		mixer_type      "software"
            }
    '';
  };
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
  programs.ncmpcpp.enable = true;
}
