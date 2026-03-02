{
  config,
  lib,
  inputs,
  pkgs,
  ssh-pubkeys,
  ...
}:
{
  disabledModules = [
    "services/audio/snapserver.nix"
  ];

  imports = [
    ../../modules/common/default.nix

    ../../modules/desktop/default.nix
    ../../modules/desktop/niri/default.nix
    ../../modules/desktop/dank-material-shell/default.nix

    ../../modules/extra.nix
    # ../../modules/network-manager.nix
    ../../modules/systemd-networkd.nix
    ../../modules/nix-extra.nix
    ../../modules/podman.nix
    # ../../modules/tor.nix
    ../../modules/bluetooth.nix
    ../../modules/ssh-authorized-keys.nix
    ../../modules/weron.nix
    ../../secrets/module.nix
    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/snapserver.nix"

    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
  time.timeZone = "America/Sao_Paulo";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_latest;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  # services.weron.vpn-ethernet.base.mac = "00-60-2F-69-63-27";
  services.weron.vpn-ip.base.ips = [ "fd00::2/128" ];

  networking = {
    wireless.iwd = {
      networks = {
        "rede Mesh 99".passphraseFile = config.age.secrets.rede-mesh-psk.path;
      };
    };

    networkmanager.ensureProfiles.profiles.mesh-guest-static-ip.ipv4.address1 = "192.168.69.202/22";
    hostName = "obsidian";
    firewall = {
      allowedTCPPorts = [
        22
        8001
      ];
    };
    interfaces = {
      enp13s0 = {
        wakeOnLan = {
          enable = true;
        };
      };
    };
  };

  systemd.network.networks = {
    "40-rede-mesh-99" = {
      matchConfig = {
        WLANInterfaceType = "station";
        Type = "wlan";
        # SSID = "rede Mesh 99";
        Name = "wlan0";
      };
      DHCP = "ipv4";
      extraConfig = ''
        [DHCPv4]
        RouteMetric=2000
        DenyList=10.0.0.0/16
      '';
      # ipv6AcceptRAConfig.RouteMetric = 1025;
    };
  };

  hardware.keyboard.qmk.enable = true;

  programs.steam = {
    enable = true;
  };

  qt.enable = true;

  # environment.systemPackages = with pkgs; [
  # snapcast
  # ];

  # services.snapserver = {
  #   enable = true;
  #   settings = {
  #     # server = {
  #     # user = "sidharta";
  #     # };
  #     stream.source = [
  #       "pipe:///run/snapserver/snapfifo?name=SnapServer-pipe"
  #       "alsa:///?name=Snapserver-alsa&device=hw:5,0&sampleformat=48000:16:1"
  #     ];
  #     http.enable = true;
  #   };
  # };
  # systemd.services.snapserver = {
  #   serviceConfig = {
  #     # DynamicUser = pkgs.lib.mkForce "false";
  #     # User = "sidharta";
  #     SupplementaryGroups = [
  #       "pipewire"
  #       "audio"
  #     ];
  #   };
  # };
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "sidharta"
      ];
    };
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.wg0.forwarding" = 1;
    "net.ipv6.conf.sidharta.forwarding" = 1;
  };

  security.pki.certificateFiles = [ ../../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

}
