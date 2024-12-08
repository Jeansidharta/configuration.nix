{
  config,
  pkgs,
  hostname,
  main-user,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  home.pointerCursor = {
    name = "Bibata Translucent";
    package = pkgs.bibata-cursors-translucent;
    size = 48;
    gtk.enable = true;
  };

  xsession.enable = true;
  xsession.windowManager.bspwm = import ./bspwm.nix { inherit config pkgs; };

  home.packages = with pkgs; [
    # === Regular Desktop ===
    btop
    firefox
    xclip
    peek
    mpv
    yazi
    bat
    sxiv
    helvum
    lmms
    eza
    plover.dev
    splatmoji
    xclip
    orca-slicer
    inkscape
    htmlq
    jq
    pavucontrol
    libnotify
    yt-dlp
    comma
    unzip

    qpwgraph
    socat
    usbutils

    kitty

    mypkgs.select-wallpaper
    mypkgs.select-wallpaper-static
    mypkgs.neovim

    # === Non free ===
    discord
    telegram-desktop

    # === Fonts ===
    jetbrains-mono
  ];

  home.stateVersion = "24.05";

  programs.wezterm = import ./wezterm.nix { inherit ; };
  programs.ewwCustom = import ./eww.nix { inherit pkgs; };
  programs.zsh = import ./zsh.nix { inherit pkgs; };
  programs.starship = import ./starship.nix { inherit ; };
  programs.git = import ./git.nix { inherit ; };
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-unwrapped;
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
  services.picom = import ./picom.nix { inherit config pkgs; };
  services.sxhkd-systemd = import ./sxhkd/default.nix { inherit config pkgs; };
  services.dunst.enable = true;
  services.udiskie.enable = true;
  systemd.user.startServices = true;
  systemd.user.services = import ./systemd-services.nix { inherit pkgs; };
}
