{
  config,
  pkgs,
  hostname,
  main-user,
  ...
}:
{
  imports = [ ./hyprland.nix ];
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
    yazi # TUI File manager
    bat # Replacement for the gnu `cat` command
    sxiv # Simple image viewer
    lmms # Music production
    eza # Replacement for the gnu `ls` command
    plover.dev # Stenography software
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

    helvum # Manipulate Pipewire connections
    qpwgraph # Manipulate Pipewire connections
    socat # Tool for connecting/debugging read/write interfaces
    usbutils # Tool for manipulating USB
    tmsu # File tagging tool

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
  programs.ewwCustom = import ./eww.nix { inherit pkgs; };
  programs.zsh = import ./zsh.nix { inherit pkgs; };
  programs.starship = import ./starship.nix { inherit ; };
  programs.git = import ./git.nix { inherit ; };
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland-unwrapped;
  };
  programs.fd.enable = true;
  programs.ripgrep.enable = true;
  programs.zk.enable = true;
  programs.zk.settings = {
    notebook = {
      dir = "~/notes";
    };
  };

  services.flameshot.enable = true;
  services.dunst.enable = true;
  services.udiskie.enable = true;
  systemd.user.startServices = true;
  systemd.user.services = import ./systemd-services.nix { inherit pkgs; };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
