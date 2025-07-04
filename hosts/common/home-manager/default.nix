{
  config,
  pkgs,
  hostname,
  main-user,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./waypaper.nix
    ./hyprlock.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
    ./eww.nix
    ./systemd-services.nix
  ];

  # home.pointerCursor = {
  #   name = "Bibata Translucent";
  #   package = pkgs.bibata-cursors-translucent;
  #   size = 48;
  #   gtk.enable = true;
  # };

  home.packages = with pkgs; [
    # === Regular Desktop ===

    btop # Process manager
    wl-clipboard # Clipboard software
    mpv # Media player
    bat # Replacement for the gnu `cat` command
    sxiv # Simple image viewer
    lmms # Music production
    eza # Replacement for the gnu `ls` command
    splatmoji # Emoji / Emoticon selector
    inkscape # Vector image editor
    htmlq # CLI tool for filtering HTML pages
    jq # CLI tool for filtering Json data
    pavucontrol # GUI for changing audio stuff
    libnotify # Send d-bus notification through the terminal
    yt-dlp # Download youtube videos
    unzip # Unzip tool
    hyprpicker # Cool color picker
    wpaperd
    imhex # A very nice hex editor
    libreoffice # Office suite

    helvum # Manipulate Pipewire connections
    qpwgraph # Manipulate Pipewire connections
    socat # Tool for connecting/debugging read/write interfaces
    usbutils # Tool for manipulating USB
    tmsu # File tagging tool
    obsidian # Note taking app
    moreutils # A collection of tools to improve bash scripting

    xh # A CURL replacement
    du-dust # A more modern du
    fselect # A file finder with SQL syntax
    mpc

    (plover.with-plugins (ps: [
      ps.plover-lapwing-aio
      (ps.plover-uinput.overrideAttrs (old: {
        propagatedBuildInputs = [
          # pkgs.python311Packages.evdev
          pkgs.xkbcommon-0-10-0
        ];
      }))
    ]))

    kitty # Backup terminal in case ghostty dies

    mypkgs.neovim
    mypkgs.sqlite-diagram

    # === Non free ===
    discord
    telegram-desktop

    # === Fonts ===
    jetbrains-mono
  ];

  home.stateVersion = "24.05";

  programs.satty = {
    enable = true;
    config = {
      general = {
        initial-tool = "brush";
        output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
        save-after-copy = true;
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
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland-unwrapped;
  };
  programs.fd.enable = true;
  programs.ripgrep.enable = true;

  programs.zk = {
    enable = true;
    settings = {
      notebook = {
        dir = "~/notes";
      };
    };
  };

  services.flameshot.enable = true;
  services.dunst.enable = true;
  services.udiskie.enable = true;
  systemd.user.startServices = true;

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
