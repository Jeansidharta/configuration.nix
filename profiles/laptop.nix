{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../modules/common/default.nix

    ../modules/desktop/default.nix
    ../modules/desktop/niri/default.nix
    ../modules/desktop/dank-material-shell/default.nix

    ../modules/network-manager.nix
    ../modules/bluetooth.nix
    ../modules/ssh-authorized-keys.nix

    ../modules/battery-savers.nix

    ../secrets/module.nix

    ../modules/extra.nix
    ../modules/nix-extra.nix
    ../modules/podman.nix
  ];

  host-data.profile = "laptop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  qt.enable = true;

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.wg0.forwarding" = 1;
    "net.ipv6.conf.sidharta.forwarding" = 1;
  };

  services.openssh = {
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [
        "sidharta"
      ];
    };
  };

  services.acpid.enable = true;
  services.acpid.logEvents = true;

  security.pki.certificateFiles = [ ../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.dank-material-shell.plugins.dms-usp-monitor.enable = lib.mkForce false;
}
