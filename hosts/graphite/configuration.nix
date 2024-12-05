{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.hostName = "graphite";

  users.users.sidharta = {
    extraGroups = [
      "wheel"
      "video"
    ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';
}
