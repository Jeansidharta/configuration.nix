{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard # Clipboard software
    sxiv # Simple image viewer
    libnotify # Send d-bus notification through the terminal
    helvum # Manipulate Pipewire connections
    qpwgraph # Manipulate Pipewire connections
    dragon-drop # Allows to drag and drop
    wiremix # TUI for configuring pipewire audio

    mpc # cli to controll the mpd daemon
    drawy # App to draw, similar do excalidraw
    syncplay

    kitty # Backup terminal in case ghostty dies
    wireshark
    drawy # whiteboard app
    yazi # File picker

    # === Non free ===
    discord
    telegram-desktop

    # === Fonts ===
    jetbrains-mono

    candy-icons
    kdePackages.breeze-icons
    adwaita-icon-theme
  ];

  home.shellAliases = {
    "dbl" = "${lib.getExe pkgs.wezterm} start --cwd .";
  };

  programs.nchat = {
    enable = true;
    settings-color = "dracula";
    settings-ui = {
      desktop_notify_enabled = 1;
      desktop_notify_active_noncurrent = 1;
      desktop_notify_inactive = 1;
      desktop_notify_connectivity = 1;
      message_open_command = "${lib.getExe pkgs.neovim} -";
      file_picker_command = "${lib.getExe pkgs.yazi} --chooser-file \"%1\"";
      home_fetch_all = 1;
    };
    settings-key = {
      backward_kill_word = "KEY_CTRLW";
      backward_word = "\\4001052"; # CTRL LEFT
      forward_word = "\\4001071"; # CTRL RIGHT
      begin_line = "KEY_HOME";
      end_line = "KEY_END";
      home = "\\33\\146"; # ALT + F
      end = "\\33\\147"; # ALT + G

      open_link = "KEY_NONE";
    };
  };

  programs.satty = {
    enable = true;
    settings = {
      general = {
        initial-tool = "brush";
        output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
        save-after-copy = true;
      };
      color-palette = {
        palette = [
          "#ff0000"
          "#00ff00"
          "#0000ff"
          "#ff66cc"
          "#00ffd5"
          "#000000"
          "#ffffff"
        ];
      };
    };
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
    '';
  };
  programs.ncmpcpp.enable = true;
}
