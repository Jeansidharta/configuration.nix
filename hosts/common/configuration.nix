{
  config,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "US/Eastern";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    # font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.timesyncd.enable = true;
  services.sshd.enable = true;
  services.sshguard.enable = true;
  services.sshguard.whitelist = [ "192.168.0.210" ];
  services.udisks2.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "intl";
    };
    windowManager.bspwm.enable = true;
  };

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "sidharta";
  };

  # Enable sound.
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

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;

  users.users.sidharta = {
    # passwordFile = config.age.secrets.userPassword.path;
    password = "1234";
    name = "sidharta";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    packages = [ pkgs.home-manager ];
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    wezterm
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      access-tokens = "github.com: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";
    };
    package = pkgs.nix;
  };

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
    };
    steam = {
      enable = true;
    };
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
      };
    };
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nix-ld.enable = true;
  services.openssh.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "24.05"; # Did you read the comment?
}
