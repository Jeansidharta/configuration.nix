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
  programs.mosh = {
    enable = true;
    openFirewall = true;
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
  networking = {
    hostName = "obsidian";
    firewall = {
      allowedTCPPorts = [
        22
        8001
        5173
        3000
      ];
      allowedUDPPorts = [
        32985
        51820
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
              address = "192.168.1.1";
              prefixLength = 32;
            }
          ];
        };
      };
    };
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          listenPort = 32985;
          privateKeyFile = config.age.secrets.wireguard-priv-key.path;
          peers = [
            {
              name = "phone";
              publicKey = "DbDVdVWefhsSeiZw+TN3Hv+gGC86TMqUGQxJFO8lG3s=";
              allowedIPs = [
                "10.0.0.5/32"
              ];
            }
          ];
        };
      };
    };
  };
  services.strongswan-swanctl = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    strongswan
  ];
  security.pki.certificateFiles = [ ../../mitmproxy-ca-cert.pem ];

  # Allow cross-compiling
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
