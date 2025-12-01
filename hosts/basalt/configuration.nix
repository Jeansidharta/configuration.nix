{
  config,
  pkgs,
  lib,
  ssh-pubkeys,
  ...
}:
{
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

  networking = {
    hostName = "basalt";

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
        "nylon"
      ];
      allowedTCPPorts = [
        22
        8001
        80
        443
      ];
      allowedUDPPorts = [
        32985
        32986
        51820
        51821
        57175
      ];
    };
    interfaces = {
      wg0 = {
        ipv4 = {
          routes = [
            {
              address = "10.0.0.0";
              prefixLength = 24;
            }
          ];
          addresses = [
            {
              address = "10.0.0.1";
              prefixLength = 32;
            }
          ];
        };
        ipv6 = {
          addresses = [
            {
              address = "2000::1";
              prefixLength = 128;
            }
          ];
          routes = [
            {
              address = "2000::0";
              prefixLength = 120;
            }
          ];
        };
      };
    };
    wireguard = {
      enable = true;
      interfaces = {
        max = {
          listenPort = 32986;
          privateKeyFile = "${pkgs.writeText "wg-key-max" "UAeG3rxC3IBltaxzUjS2/x6JWi5fESM/3fqmEn42knY="}";
          peers = [
            {
              name = "max";
              publicKey = "2ac7/D/IKDyzESQ2NmLVEl25nirwYfgh1a4NUYBCeQM=";
              allowedIPs = [
                "10.1.0.12/32"
                "2001::12/128"
              ];
            }
          ];
        };
        wg0 = {
          listenPort = 32985;
          privateKeyFile = "${pkgs.writeText "wg-key-wg0" "aD4yizZ3tEpw3cdOhN0R+yrtc43NUFwb8ta3vw+cdmw="}";
          peers = [
            {
              name = "phone";
              publicKey = "DbDVdVWefhsSeiZw+TN3Hv+gGC86TMqUGQxJFO8lG3s=";
              allowedIPs = [
                "10.0.0.12/32"
                "2000::12/128"
              ];
            }
          ];
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      webroot = "/var/lib/acme/acme-challenge/";
      email = "jeansidharta@gmail.com";
      # extraDomainNames = [
      #   "walmart-goback-2.sidharta.xyz"
      # ];
    };
  };

  services.syncplay = {
    enable = true;
    ready = false;
    chat = false;
    permanentRooms = [ "Sala" ];
    package = pkgs.syncplay-nogui;
  };

  services.nginx = {
    enable = true;
    virtualHosts."walmart-goback-2.sidharta.xyz" = {
      enableACME = true;
      addSSL = true;
      locations."/" = {
        root = "/var/www/walmart-goback-2";
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

  environment.systemPackages = with pkgs; [
    git
    zsh
    tmux
    mitmproxy
    busybox
    jq
    neovim
    tcpdump
    nylon-wg
    unar
  ];

  systemd.services.nylon = {
    enable = true;
    unitConfig = {
      Description = "Nylon network";
      After = "network-online.target nss-lookup.target";
      Wants = "network-online.target nss-lookup.target";
      PartOf = "nylon.target";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nylon-wg}/bin/nylon run -v -n /home/sidharta/nylon/node.yaml -c /home/sidharta/nylon/central.yaml";
      Restart = "always";
      RestartSec = 10;
    };
    wantedBy = [ "multi-user.target" ];
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
