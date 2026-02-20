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
      ../../modules/network-manager.nix
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

    networkmanager.ensureProfiles = {
      secrets.entries = [
        {
          file = config.age.secrets.coffee-psk.path;
          matchType = "802-11-wireless";
          matchId = "coffee";
          matchSetting = "802-11-wireless-security";
          key = "psk";
        }
      ];
      profiles = {
        mesh-guest-static-ip = {
          ipv4.address1 = "192.168.69.200/22";
          connection = {
            autoconnect = true;
            interface-name = "wlan0";
          };
        };

        clients-bridge = {
          connection = {
            id = "clients-bridge";
            uuid = "6de119a1-a336-48bd-861a-00d07dcd99c3";
            type = "bridge";
            interface-name = "bridge0";
            autoconnect = true;
            autoconnect-priority = 10;
            autoconnect-slaves = "1"; # Bring all slaves up with this connection
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.0.1/24";
            dns = "8.8.8.8;1.1.1.1;";
            forwarding = "1";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "link-local";
          };
        };
        coffee = {
          connection = {
            id = "coffee";
            uuid = "a4a31f8e-fed9-47b5-b396-8eb726d4d1a8";
            type = "wifi";
            interface-name = "wlu2";

            controller = "bridge0";
            port-type = "bridge";
          };

          wifi = {
            mode = "ap";
            ssid = "coffee";
          };

          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            pairwise = "ccmp";
          };

          ipv4 = {
            method = "disabled";
          };

          ipv6 = {
            method = "link-local";
          };
        };
        ethernet-router = {
          connection = {
            id = "ethernet-router";
            type = "ethernet";

            controller = "bridge0";
            port-type = "bridge";
          };
          ipv4 = {
            method = "disabled";
          };
          ipv6 = {
            method = "link-local";
          };
        };
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

  environment.systemPackages = with pkgs; [
    mitmproxy
    tcpdump
  ];

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
