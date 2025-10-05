{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  time.timeZone = "US/Eastern";

  programs.steam = {
    enable = true;
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  users.groups.proxyuser = { };
  users.users.sidharta.openssh.authorizedKeys.keys = [
    # My partner's laptop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvVcRT7OfCgWBxvqqfw1u7xZnsrTXGaommf2m6AVlGd suzana@Nemo"

  ];
  users.users.proxyuser = {
    name = "proxyuser";
    group = "proxyuser";
    openssh.authorizedKeys.keys = [
      # Raspberry PI
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDig6qJstpy9HOVdJkvhc15ywIdRwUiH5uZ7lbwNW0rZ jeansidharta@gmail.com"
      # My phone
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF7Zp5PotpXLi0ZSby7zm1B2Ca6GyIL76Rew9zzDCTKu u0_a270@localhost"
      # My laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6KBaW5uNXP3Zav9MYReG37mkYB8yBU2l0RbnS6H2tT sidharta@graphite"
      # My partner's laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvVcRT7OfCgWBxvqqfw1u7xZnsrTXGaommf2m6AVlGd suzana@Nemo"
    ];
    isNormalUser = true;
    extraGroups = [ ];
  };
  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "sidharta"
        "proxyuser"
      ];
      UseDns = true;
    };
    extraConfig =
      let
        permitOpen = [
          "localhost:3000"
          "localhost:8202"
          "localhost:8000"
          "localhost:8080"
          "localhost:443"
          "localhost:80"
          "192.168.0.210:443"
          "192.168.0.210:80"
        ];
        permitOpenStr = lib.strings.concatStringsSep " " permitOpen;
      in
      ''
        Match User proxyuser
          PermitOpen ${permitOpenStr}
          PermitListen 2222
          Banner ${import ./ssh-banner.nix { pkgs = pkgs; }}
          ForceCommand echo 'This user is for TCP forwarding only. Allowed forwards are ${permitOpenStr}'
      '';
  };

  age.secrets.wireguard-priv-key = {
    file = ../../secrets/wireguard.age;
  };
  age.secrets.wireguard-max = {
    file = ../../secrets/wireguard-max.age;
  };
  networking = {
    hostName = "obsidian";
    hosts = {
      "192.168.0.210" = [ "rpi" ];
    };
    firewall = {
      trustedInterfaces = [ "wg0" ];
      allowedTCPPorts = [
        22
        8001
      ];
      allowedUDPPorts = [
        32985
        32986
        51820
      ];
    };
    nat = {
      enable = true;
      internalInterfaces = [ "max" ];
      externalInterface = "enp13s0";
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
      max = {
        ipv4 = {
          routes = [
            {
              address = "10.0.0.0";
              prefixLength = 24;
            }
          ];
          addresses = [
            {
              address = "192.168.1.1";
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
        };
      };
    };
    wireguard = {
      enable = true;
      interfaces = {
        max = {
          listenPort = 32986;
          privateKeyFile = config.age.secrets.wireguard-max.path;
          peers = [
            {
              name = "phone";
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
          privateKeyFile = config.age.secrets.wireguard-priv-key.path;
          peers = [
            # {
            #   name = "rpi";
            #   publicKey = "D2+YmRmpHZmMIYGP43bc7rNN9XaByQojvFs4/LlmQwM=";
            #   endpoint = "192.168.0.210:55192";
            #   allowedIPs = [
            #     "10.0.0.5/32"
            #     "2000::5/128"
            #   ];
            # }
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
                "10.0.2.0/24"
                "2000::12/128"
              ];
            }
          ];
        };
      };
    };
  };

  security.pki.certificateFiles = [ ../../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
