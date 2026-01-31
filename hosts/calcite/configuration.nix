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
    ../../modules/network-manager.nix
    ../../secrets/module.nix
    ../../modules/nix-extra.nix
    ../../secrets/module.nix

    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-124b.psf.gz";
  networking.hostName = "calcite";
  time.timeZone = "US/Eastern";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [
    {
      device = "/dev/disk/by-partlabel/disk-ssd-plainSwap";
    }
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      vpl-gpu-rt
      intel-vaapi-driver
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

  services.transmission = {
    enable = true;
    openFirewall = true;
    package = pkgs.transmission_4;
  };
}
