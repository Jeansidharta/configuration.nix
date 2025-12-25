{
  config,
  pkgs,
  lib,
  ssh-pubkeys,
  inputs,
  ...
}:
{
  imports =
    let
      inherit (inputs.nixos-raspberrypi.nixosModules)
        raspberry-pi-4
        usb-gadget-ethernet
        sd-image
        ;
    in
    [
      raspberry-pi-4.base
      usb-gadget-ethernet
      sd-image

      ../../modules/common/default.nix
      ../../modules/tor.nix
      ../../modules/ssh-authorized-keys.nix
      ../../modules/proxyuser.nix
    ];
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "root"
        "sidharta"
      ];
      UseDns = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.loader.raspberryPi.bootloader = "kernel";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = config.users.users.sidharta.openssh.authorizedKeys.keys;
  };

  networking = {
    hostName = "vivianite";

    wireless = {
      enable = true;
      networks = {
        Hannah = {
          psk = "fffeee11";
        };
      };
    };

    firewall = {
      trustedInterfaces = [
        "wg0"
      ];
      allowedTCPPorts = [
        22
      ];
      allowedUDPPorts = [
      ];
    };
    wireguard = {
      enable = true;
    };
  };

  services.tor.settings = {
    HiddenServiceDir = "/var/lib/tor/hidden-ssh";
    HiddenServicePort = 22;
    HiddenServiceDirGroupReadable = true;
  };

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberryPi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
