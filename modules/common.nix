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

  security.sudo.extraConfig = ''
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend
    sidharta ALL= NOPASSWD: ${sleep-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl poweroff
    sidharta ALL= NOPASSWD: ${shutdown-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl reboot
    sidharta ALL= NOPASSWD: ${reboot-script}
  '';

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

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.timesyncd.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
  };

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;

  users.users.sidharta = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$gBDB9SKOqnh3cnPYEaxgj0$HCawgsRBrhcXvjvg8cSytRYtlExK/yaj219Fm8J7Jx3";
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    wireguard-tools
    agenix
    nylon-wg
    zsh
    tmux
    busybox
    jq
    sleep-script
    shutdown-script
    reboot-script
  ];

  networking.wireguard.enable = true;
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

  services.nylon-wg = {
    enable = true;
    centralConfig = "/var/nylon/central.yaml";
    node = {
      id = config.networking.hostName;
      logPath = "/var/nylon/log";
    };
  };
  networking.firewall.trustedInterfaces = [ config.services.nylon-wg.node.interface ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
    ];
    allowedUDPPorts = [ 4789 ];
  };

  system.stateVersion = "24.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
