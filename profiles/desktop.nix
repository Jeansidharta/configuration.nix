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

    ../modules/systemd-networkd.nix
    ../modules/bluetooth.nix
    ../modules/ssh-authorized-keys.nix

    ../secrets/module.nix

    ../modules/extra.nix
    ../modules/nix-extra.nix
    ../modules/podman.nix
  ];

  host-data.profile = "desktop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.steam = {
    enable = true;
  };

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

  security.pki.certificateFiles = [ ../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.dank-material-shell.plugins.dms-usp-monitor.enable = lib.mkForce false;
}
