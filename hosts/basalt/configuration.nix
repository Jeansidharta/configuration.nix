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
  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge/";
      email = "jeansidharta@gmail.com";
    };
  };

  networking = {
    wireless = {
      interfaces = [ "wlan0" ];
      secretsFile = config.age.secrets.wifi.path;
      networks = {
        "rede Mesh 99".pskRaw = "ext:rede-mesh-99";
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

  services.hostapd = {
    enable = true;
    radios.wlu2 = {
      channel = 1;
      networks.wlu2 = {
        ssid = "coffee";
        authentication.saePasswords = [ { passwordFile = config.age.secrets.coffee-psk.path; } ];
      };
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
          Address = "192.168.0.1/24";
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

      "40-rede-mesh-99" = {
        matchConfig = {
          WLANInterfaceType = "station";
          Type = "wlan";
          SSID = "'rede Mesh 99'";
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

  services.nginx = {
    enable = true;
    virtualHosts."walmart-goback-2.sidharta.xyz" = {
      enableACME = true;
      addSSL = true;
      locations."/" = {
        root = "/var/www/walmart-goback-2";
        tryFiles = "$uri /index.html";
      };
      locations."/api" = {
        proxyPass = "http://192.168.0.153:8001/";
        extraConfig = ''
          rewrite /api/(.*) /$1 break;
          proxy_redirect     off;
          proxy_set_header   Host $host;
        '';
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      dhcp-range = [
        "192.168.0.100,192.168.0.200,2d"
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
