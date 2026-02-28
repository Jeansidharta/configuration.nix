{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;

  hm-module =
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
        syncplay

        kitty # Backup terminal in case ghostty dies
        wireshark
        yazi # File picker

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

      programs.yt-dlp = {
        enable = true;
        settings = {
          sponsorblock-mark = "all";
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
    };
in
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  home-manager.users.sidharta.imports = [
    hm-module
  ];

  nixpkgs.overlays = [
    (mkUnstable "wezterm")
    (overlay-flake "wiremix")
  ];
  hardware.graphics.enable = true;
  services.udisks2.enable = true;

  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  users.users.sidharta = {
    extraGroups = [
      "dialout"
      "pipewire"
    ];
    packages = [ pkgs.home-manager ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.udev.extraRules = ''
    # For developing with a Raspberry PI
    ATTRS{vendor}=="RPI", ATTRS{model}=="RP2", MODE="0666"

    # Serial port of my keyboard for Stenography
    ATTRS{product}=="stenidol", SYMLINK+="stenidol", OWNER="sidharta"

    ATTRS{serial}=="BZEEk13AL19", MODE="0666"
    ATTR{manufacturer}=="Stenograph", MODE="0666"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  security.rtkit.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    pkgs.dbus.lib
    pkgs.libGL
    pkgs.libx11
    pkgs.libxext
    pkgs.libxcursor
    pkgs.libxinerama
    pkgs.libxi
    pkgs.libxfixes
    pkgs.libxrandr
    pkgs.libxscrnsaver
    pkgs.libxxf86vm
    pkgs.libxkbcommon
    pkgs.kdePackages.wayland
    pkgs.libpulseaudio
    pkgs.alsa-lib
    pkgs.sndio
    pkgs.nas
  ];
}
