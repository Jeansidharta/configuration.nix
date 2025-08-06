{
  config,
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
  services.sshd.enable = true;
  services.udisks2.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.greetd = {
    settings = rec {
      initial_session =
        let
          systemctl = "${pkgs.systemd}/bin/systemctl";
          startup = pkgs.writeScript "startup" ''
            ${systemctl} --user import-environment PATH
            exec ${pkgs.uwsm}/bin/uwsm start hyprland
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
  ];

  age.secrets.nix-github-token = {
    file = ../../secrets/nix-github-token.age;
    owner = "sidharta";
  };
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      # Enable hyprland cachix
      substituters = [
        "https://hyprland.cachix.org"
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
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

  programs.nix-index-database.comma.enable = true;
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
  services.openssh.enable = true;

  services.tor = {
    enable = true;
    client.enable = true;
    # controlSocket.enable = true;
    settings = {
      ControlPort = 9051;
      HashedControlPassword = "16:DB07FBCA1CE2B6A360D7B98EF09D2877ECEE44B0750DD72DCFA3DE0263";
    };
  };

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    4030
    9000
    8001
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "24.05";
}
