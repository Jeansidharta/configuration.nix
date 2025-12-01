{
  config,
  lib,
  pkgs,
  ssh-pubkeys,
  ...
}:
{
  disabledModules = [
    "services/audio/snapserver.nix"
  ];

  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  time.timeZone = "US/Eastern";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  users.users.sidharta.extraGroups = [
    "tor"
    "docker"
  ];
  services.tor = {
    enable = true;
    client.enable = true;
    # controlSocket.enable = true;
    settings = {
      ControlPort = 9051;
      HashedControlPassword = "16:DB07FBCA1CE2B6A360D7B98EF09D2877ECEE44B0750DD72DCFA3DE0263";
    };
  };

  hardware.keyboard.qmk.enable = true;

  programs.steam = {
    enable = true;
  };

  qt.enable = true;

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    snapcast
    nylon-wg
  ];
  networking.hosts = {
    "fd00::2:2" = [ "suzana.wg" ];
    "fd00::1" = [ "rpi.wg" ];
    "fd00::1:2" = [ "obsidian.wg" ];
    "fd00::1:3" = [ "graphite.wg" ];
  };

  virtualisation = {
    virtualbox.host.enable = true;
    docker = {
      enable = true;
      daemon.settings = {
        ipv6 = true;
        fixed-cidr-v6 = "fd10::/80";
        metrics-addr = "0.0.0.0:9323";
      };
    };
  };
  security.wrappers.batata = {
    source = "${pkgs.coreutils-full}/bin/whoami";
    setuid = true;
    setgid = true;
    owner = "root";
    group = "root";
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

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

  age.secrets.wireguard-priv-key = {
    file = ../../secrets/wireguard.age;
  };
  networking = {
    hostName = "obsidian";
    hosts = {
      "192.168.0.210" = [ "rpi" ];
    };
    firewall = {
      trustedInterfaces = [
        "wg0"
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
              address = "10.0.0.5";
              prefixLength = 32;
            }
          ];
        };
        ipv6 = {
          addresses = [
            {
              address = "2000::5";
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
      interfaces = {
        wg0 = {
          listenPort = 32985;
          privateKeyFile = config.age.secrets.wireguard-priv-key.path;
          peers = [
            {
              name = "suzana";
              publicKey = "wthF4Kyo+6wYWXgw9WKbz0ljb0YRrh2+ygf0DaB7BF4=";
              allowedIPs = [
                "10.0.0.8/32"
                "2000::8/128"
              ];
            }
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
  systemd = {
    # targets.innernet = {
    #   unitConfig = {
    #     Description = "Target to allow restarting and stopping of all parts of innernet";
    #   };
    # };
    targets.nylon = {
      unitConfig = {
        Description = "Target to allow restarting and stopping of all parts of nylon";
      };
    };
    services.nylon = {
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
    # services.innernet-sidharta = {
    #   unitConfig = {
    #     Description = "innernet client daemon for sidharta";
    #     After = "network-online.target nss-lookup.target";
    #     Wants = "network-online.target nss-lookup.target";
    #     PartOf = "innernet.target";
    #   };
    #
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.innernet}/bin/innernet up sidharta --daemon --interval 60";
    #     Restart = "always";
    #     RestartSec = 10;
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
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
