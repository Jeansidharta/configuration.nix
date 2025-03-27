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
    ./hyprlock.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
    ./eww.nix
    ./systemd-services.nix
  ];
  nixpkgs.config.allowUnfree = true;

  home.pointerCursor = {
    name = "Bibata Translucent";
    package = pkgs.bibata-cursors-translucent;
    size = 48;
    gtk.enable = true;
  };

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

    # === Non free ===
    discord
    telegram-desktop

    # === Fonts ===
    jetbrains-mono
  ];

  home.stateVersion = "24.05";

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
    systemdTarget = "hyprland-session.target";
  };
  services.swww = {
    enable = true;
    systemdService = true;
    systemdTarget = "hyprland-session.target";
  };
  programs.waypaper = {
    enable = true;
    settings = {
      folder = "/home/sidharta/wallpapers";
      subfolders = true;
      sort = "random";
    };
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
