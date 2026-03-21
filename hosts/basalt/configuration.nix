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
        raspberry-pi-5
        sd-image
        ;
    in
    [
      raspberry-pi-5.base
      raspberry-pi-5.page-size-16k
      sd-image
      ../../modules/common/default.nix
      ../../modules/proxyuser.nix
      ../../modules/systemd-networkd.nix
      ../../modules/podman.nix
      ../../modules/ssh-authorized-keys.nix
      ../../modules/weron.nix
      ../../modules/netlify-ddns.nix
      ../../secrets/module.nix
    ];
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "root"
      ];
    };
  };

  nixpkgs.hostPlatform = "aarch64-linux";

  boot.loader.raspberry-pi.bootloader = "kernel";

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      ssh-pubkeys.obsidian.sidharta
      ssh-pubkeys.phone
      ssh-pubkeys.graphite.sidharta
    ];
  };
  users.users.sidharta = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$gBDB9SKOqnh3cnPYEaxgj0$HCawgsRBrhcXvjvg8cSytRYtlExK/yaj219Fm8J7Jx3";
    openssh.authorizedKeys.keys = [
      ssh-pubkeys.obsidian.sidharta
      ssh-pubkeys.phone
      ssh-pubkeys.graphite.sidharta
    ];
  };

  services.weron.vpn-ip.base.ip.address = "fd00::1";
  services.weron.signaler = {
    enable = true;
  };

  networking = {
    wireless = {
      interfaces = [ "wlan0" ];
      secretsFile = config.age.secrets.wifi.path;
      networks = {
        "rede Mesh 99" = {
          pskRaw = "ext:rede-mesh-99";
          bssid = "3e:64:cf:8c:24:cb";
        };
        "rede Mesh 99_Guest".pskRaw = "ext:rede-mesh-99";
      };
    };

    hostName = "basalt";
    firewall.trustedInterfaces = [
      "wlu2"
      "end0"
      "bridge0"
    ];
    nat = {
      enable = true;
      internalInterfaces = [
        "bridge0"
      ];
      externalInterface = "wlan0";
    };
  };

  systemd.network = {
    netdevs = {
      "10-bridge" = {
        enable = true;
        netdevConfig = {
          Kind = "bridge";
          Name = "bridge0";
        };
      };
    };
    networks = {
      "40-bridge" = {
        matchConfig = {
          Name = "bridge0";
        };
        networkConfig = {
          Address = [
            "192.168.0.1/24"
            "fd01::1/64"
          ];
        };
      };
      "40-coffee-ap" = {
        matchConfig = {
          WLANInterfaceType = "ap";
          # Name = "wlu2";
        };
        networkConfig = {
          Bridge = "bridge0";
        };
        DHCP = "no";
      };
      "40-no-dhcp-ethernet" = {
        matchConfig = {
          Type = "ether";
        };
        networkConfig = {
          Bridge = "bridge0";
          LinkLocalAddressing = "ipv6";
        };
        DHCP = "no";
      };
      "40-rede-mesh-99-guest" = {
        matchConfig = {
          WLANInterfaceType = "station";
          Type = "wlan";
          SSID = "'rede Mesh 99_Guest'";
          Name = "wlan0";
        };
        networkConfig = {
          IPv6LinkLocalAddressGenerationMode = "stable-privacy";
          Address = "192.168.69.200/22";
          Gateway = "192.168.68.1";
          DNS = "1.1.1.1";
          DHCP = "no";
        };
      };
      "40-rede-mesh-99" = {
        matchConfig = {
          WLANInterfaceType = "station";
          Type = "wlan";
          SSID = "'rede Mesh 99'";
          Name = "wlan0";
        };
        DHCP = "ipv4";
        networkConfig.IPv6LinkLocalAddressGenerationMode = "stable-privacy";
        extraConfig = ''
          [DHCPv4]
          RouteMetric=2000
          DenyList=10.0.0.0/16
        '';
        # ipv6AcceptRAConfig.RouteMetric = 1025;
      };
    };
  };

  # services.syncplay = {
  #   enable = true;
  #   ready = false;
  #   chat = false;
  #   port = 8202;
  #   interfaceIpv6 = "fd00::10:2";
  #   ipv6Only = true;
  #   permanentRooms = [ "Sala" ];
  #   package = pkgs.syncplay-nogui;
  # };

  services.resolved.enable = lib.mkForce false;
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      log-queries = true;
      # log-debug = true;
      log-dhcp = true;
      # no-daemon = true;
      enable-ra = true;
      dhcp-authoritative = true;
      dhcp-range = [
        "192.168.0.100,192.168.0.200,2d"
        # "::,constructor:bridge0,ra-only,slaac,64"
      ];
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      interface = [
        "bridge0"
      ];
      no-hosts = true;
      addn-hosts = "${pkgs.writeText "dnsmasq-domains" ''
        fd00::1 basalt.wg
        fd00::2 obsidian.wg
        fd00::3 graphite.wg
        fd00::4 phone.wg
        fd00::10:1 dnsmasq.wg
        fd00::10:2 syncplay.wg
        fd00::1:1 goldfish.wg
      ''}";
    };
  };

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];
}
