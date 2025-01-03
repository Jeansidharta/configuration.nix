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

  users.users.sidharta = {
    extraGroups = [
      "wheel"
      "video"
    ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

  specialisation.on_battery = {
    inheritParentConfig = true;
    configuration = {
      system.nixos.tags = [ "on_battery" ];
      hardware.bluetooth.enable = lib.mkForce false;
      hardware.bluetooth.powerOnBoot = lib.mkForce false;
      services.blueman.enable = lib.mkForce false;

      home-manager.users.sidharta = {
        services.picom.enable = lib.mkForce false;
        programs.starship.enable = lib.mkForce false;
        systemd.user.services.eww-bar-selector = lib.mkForce { };
      };
    };
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
