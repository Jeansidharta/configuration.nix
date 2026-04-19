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
    ../../profiles/desktop.nix

    "${inputs.nixpkgs-unstable}/nixos/modules/services/audio/snapserver.nix"

    ./hardware-configuration.nix
    ./disko-config.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
  ];
  time.timeZone = "America/Sao_Paulo";

  # services.weron.vpn-ip.base.ip.address = "fd00::2";

  networking = {
    wireless = {
      secretsFile = config.age.secrets.wifi.path;
      networks = {
        "rede Mesh 99".pskRaw = "ext:rede-mesh-99";
        "Hannah".psk = "fffeee11";
      };
    };

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
        SSID = "'rede Mesh 99'";
        Name = "wlp14s0";
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
}
