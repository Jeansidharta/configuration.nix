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
    ../../modules/extra.nix
    ../../modules/network-manager.nix
    ../../modules/nix-extra.nix
    ../../modules/docker.nix
    ../../modules/tor.nix
    ../../modules/bluetooth.nix
    ../../modules/ssh-authorized-keys.nix
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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  networking.networkmanager.ensureProfiles.profiles.wired-routerless = {
    connection = {
      id = "wired-routerless";
      interface-name = "enp15s0u1u2";
      type = "ethernet";
    };
    ipv4 = {
      method = "link-local";
    };
    ipv6 = {
      method = "link-local";
    };
  };

  hardware.keyboard.qmk.enable = true;

  programs.steam = {
    enable = true;
  };

  qt.enable = true;

  environment.systemPackages = with pkgs; [
    snapcast
  ];
  networking.hosts = {
    "fd00::2:2" = [ "suzana.wg" ];
    "fd00::1" = [ "rpi.wg" ];
    "fd00::1:2" = [ "obsidian.wg" ];
    "fd00::1:3" = [ "graphite.wg" ];
  };

  users.users.sidharta.openssh.authorizedKeys.keys = [
    ssh-pubkeys.goldfish.suzana
    ssh-pubkeys.basalt.sidharta
    ssh-pubkeys.phone
  ];
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
      UseDns = true;
    };
  };

  networking = {
    hostName = "obsidian";
    hosts = {
      "192.168.0.210" = [ "rpi" ];
    };
    firewall = {
      trustedInterfaces = [
        "sidharta"
      ];
      allowedTCPPorts = [
        22
        8001
      ];
      allowedUDPPorts = [
        32985
        32986
        51820
        57175
      ];
    };
    interfaces = {
      wlp14s0 = {
        wakeOnLan = {
          enable = true;
        };
      };
      enp13s0 = {
        wakeOnLan = {
          enable = true;
        };
      };
    };
    wireguard = {
    };
  };
  networking.nftables = {
    enable = true;
    tables = {
      innernet-forwarding = {

        family = "inet";
        # Enable routing between my manual wireguard network and innernet's managed network
        content = ''
          chain srcnat {
              type nat hook postrouting priority srcnat; policy accept;
              iifname "wg0" oifname "sidharta" counter masquerade
          }
        '';
      };
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
