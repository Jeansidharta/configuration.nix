{
  config,
  pkgs,
  ...
}:

let
  reboot-script = pkgs.writeScriptBin "rrr" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl reboot "$@"
  '';

  sleep-script = pkgs.writeScriptBin "zzz" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl suspend "$@"
  '';

  shutdown-script = pkgs.writeScriptBin "xxx" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl poweroff "$@"
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  security.sudo.extraConfig = ''
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend
    sidharta ALL= NOPASSWD: ${sleep-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl poweroff
    sidharta ALL= NOPASSWD: ${shutdown-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl reboot
    sidharta ALL= NOPASSWD: ${reboot-script}
  '';

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  networking.hosts = {
    "::1" = [
      "ip6-localhost"
      "ip6-loopback"
    ];
    "fe00::0" = [ "ip6-localnet" ];
    "ff00::0" = [ "ip6-mcastprefix" ];
    "ff02::1" = [ "ip6-allnodes" ];
    "ff02::2" = [ "ip6-allrouters" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    # font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };
  hardware.keyboard.qmk.enable = true;
  hardware.graphics.enable = true;

  services.timesyncd.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
  };
  services.udisks2.enable = true;

  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Required by Hyprlock
  security.pam.services.hyprlock = { };

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
    name = "sidharta";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "tor"
      "dialout"
    ];
    shell = pkgs.zsh;
    packages = [ pkgs.home-manager ];
    hashedPassword = "$y$j9T$gBDB9SKOqnh3cnPYEaxgj0$HCawgsRBrhcXvjvg8cSytRYtlExK/yaj219Fm8J7Jx3";
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    innernet
    wireguard-tools
    xwayland-satellite
    sleep-script
    shutdown-script
    reboot-script
  ];

  networking.wireguard.enable = true;
  age.secrets.wireguard-priv-key = {
    file = ../../secrets/wireguard.age;
  };
  age.secrets.nix-github-token = {
    file = ../../secrets/nix-github-token.age;
    owner = "sidharta";
  };
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      substituters = [ ];
      trusted-public-keys = [ ];
      max-jobs = 4;

      warn-dirty = false;
      allowed-users = [ "@wheel" ];
      trusted-users = [
        "root"
        "sidharta"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    extraOptions = ''
            !include ${config.age.secrets.nix-github-token.path}
      	  allow-import-from-derivation = true
    '';
  };

  # desktops.customHyprland.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;
  niri-flake.cache.enable = false;
  services.greetd = {
    settings = rec {
      initial_session =
        let
          systemctl = "${pkgs.systemd}/bin/systemctl";
          startup = pkgs.writeScript "startup" ''
            ${systemctl} --user import-environment PATH
            exec ${pkgs.niri}/bin/niri-session
          '';
        in
        {
          user = "sidharta";
          command = startup;
        };
      default_session = initial_session;
    };
    enable = true;
  };
  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
      defaultEditor = true;
    };
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
      };
    };
  };
  programs.nix-ld.enable = true;

  services.tor = {
    enable = true;
    client.enable = true;
    # controlSocket.enable = true;
    settings = {
      ControlPort = 9051;
      HashedControlPassword = "16:DB07FBCA1CE2B6A360D7B98EF09D2877ECEE44B0750DD72DCFA3DE0263";
    };
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
    ];
    allowedUDPPorts = [ 4789 ];
  };

  system.stateVersion = "24.05";
}
