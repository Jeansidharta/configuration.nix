{
  config,
  lib,
  pkgs,
  inputs,
  ssh-pubkeys,
  ...
}:
{
  imports = [
    ../../modules/common/default.nix
    ../../modules/desktop/default.nix
    # ../../modules/nylon-wg.nix
    ../../modules/network-manager.nix
    ../../modules/nix-extra.nix
    ../../modules/podman.nix
    ../../modules/tor.nix
    ../../modules/bluetooth.nix
    ../../modules/ssh-authorized-keys.nix
    ../../modules/battery-savers.nix
    ../../secrets/module.nix

    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];

  networking = {
    hostName = "graphite";
    networkmanager.ensureProfiles.profiles.mesh-guest-static-ip.ipv4.address1 = "192.168.69.201/22";

    firewall = {
      trustedInterfaces = [
        "ve-debian"
      ];
    };
  };

  time.timeZone = "America/Sao_Paulo";

  programs.steam.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    # publish = {
    #   enable = true;
    #   addresses = true;
    #   domain = true;
    #   hinfo = true;
    #   userServices = true;
    #   workstation = true;
    # };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = [ ];

  services.transmission = {
    enable = true;
    openFirewall = true;
    package = pkgs.transmission_4;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-vaapi-driver
      intel-media-driver
    ];
  };

  users.users = {
    sidharta = {
      extraGroups = [
        "wheel"
        "video"
        "transmission"
      ];
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  services.acpid.enable = true;
  services.acpid.logEvents = true;

  services.acpid.handlers.mute = {
    event = "button/mute";
    action = "${pkgs.pulseaudio}/bin/pamixer --toggle-mute";
  };
  services.acpid.handlers.volumedown = {
    event = "button/volumedown";
    action = "${pkgs.pulseaudio}/bin/pamixer --unmute && ${pkgs.pulseaudio}/bin/pamixer --decrease 10";
  };
  services.acpid.handlers.volumeup = {
    event = "button/volumeup";
    action = "${pkgs.pulseaudio}/bin/pamixer --unmute && ${pkgs.pulseaudio}/bin/pamixer --increase 10";
  };

  services.acpid.handlers.microphone = {
    event = "video/f20";
    action = "${pkgs.libnotify}/bin/notify-send TODO";
  };
  services.acpid.handlers.backlightup = {
    event = "video/brightnessup";
    action = "${pkgs.libnotify}/bin/notify-send TODO";
  };
  services.acpid.handlers.backlightdown = {
    event = "video/brightnessdown";
    action = "${pkgs.libnotify}/bin/notify-send TODO";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
