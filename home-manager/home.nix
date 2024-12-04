{
  config,
  pkgs,
  ...
}:
{
  imports = import ./modules/default.nix;

  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.pointerCursor = {
    name = "Bibata Translucent";
    package = pkgs.bibata-cursors-translucent;
    size = 48;
    gtk.enable = true;
  };

  xsession.enable = true;
  xsession.windowManager.bspwm = import ./configuration/bspwm.nix { inherit config pkgs; };

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

  programs.wezterm = import ./configuration/wezterm.nix { inherit ; };
  programs.ewwCustom = import ./configuration/eww.nix { inherit ; };
  programs.zsh = import ./configuration/zsh.nix { inherit pkgs; };
  programs.starship = import ./configuration/starship.nix { inherit ; };
  programs.git = import ./configuration/git.nix { inherit ; };
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
  services.picom = import ./configuration/picom.nix { inherit config pkgs; };
  services.sxhkd-systemd = import ./configuration/sxhkd/default.nix { inherit config pkgs; };
  services.wallpaper-manager = import ./configuration/wallpaper-manager.nix {
    inherit (pkgs.mypkgs) wallpaper-manager;
  };
  services.syncplay = import ./configuration/syncplay.nix { inherit ; };
  services.dunst.enable = true;
  services.udiskie.enable = true;
  systemd.user.startServices = true;
  systemd.user.services = import ./systemd-services.nix { inherit pkgs; };
}
