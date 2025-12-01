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
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  networking.hostName = "graphite";
  time.timeZone = "US/Eastern";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      vaapiIntel
      intel-media-driver
    ];
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        ssh-pubkeys.obsidian.sidharta
      ];
    };
    sidharta = {
      extraGroups = [
        "wheel"
        "video"
        "transmission"
      ];
      openssh.authorizedKeys.keys = [
        ssh-pubkeys.obsidian.sidharta
      ];
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  # specialisation.on_battery = {
  #   inheritParentConfig = true;
  #   configuration = {
  #     system.nixos.tags = [ "on_battery" ];
  #     hardware.bluetooth.enable = lib.mkForce false;
  #     hardware.bluetooth.powerOnBoot = lib.mkForce false;
  #     services.blueman.enable = lib.mkForce false;
  #
  #     home-manager.users.sidharta = {
  #       services.picom.enable = lib.mkForce false;
  #       programs.starship.enable = lib.mkForce false;
  #       systemd.user.services.eww-bar-selector = lib.mkForce { };
  #     };
  #   };
  # };

  services.transmission = {
    enable = true;
    openFirewall = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

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

  systemd = {
    targets.innernet = {
      unitConfig = {
        Description = "Target to allow restarting and stopping of all parts of innernet";
      };
    };
    services.innernet-sidharta = {
      unitConfig = {
        Description = "innernet client daemon for sidharta";
        After = "network-online.target nss-lookup.target";
        Wants = "network-online.target nss-lookup.target";
        PartOf = "innernet.target";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.innernet}/bin/innernet up sidharta --daemon --interval 60";
        Restart = "always";
        RestartSec = 10;
      };
      wantedBy = [ "multi-user.target" ];
    };
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
}
