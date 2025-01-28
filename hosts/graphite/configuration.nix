{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.hostName = "graphite";
  time.timeZone = "America/Sao_Paulo";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      vaapiIntel
      intel-media-driver
    ];
  };

  users.users =
    let
      obsidianPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5TwFvhFpbcI1h7LAdC1FPo7Y/nYfwqYVjpZ0Ns9N7+";
    in
    {
      root = {
        openssh.authorizedKeys.keys = [
          obsidianPubKey
        ];
      };
      sidharta = {
        extraGroups = [
          "wheel"
          "video"
          "transmission"
        ];
        openssh.authorizedKeys.keys = [
          obsidianPubKey
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
