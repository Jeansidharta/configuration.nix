{
  pkgs,
  lib,
  ssh-pubkeys,
  config,
  ...
}:
{
  modules = [
    ../../modules/common/default.nix
    ./hardware-configuration.nix
  ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Required for the Zero's wifi firmware.
  hardware.enableRedistributableFirmware = true;

  # Enable console on UART pins.
  boot.kernelParams = [ "console=ttyAML0,115200" ];
  # For more DT overlays, see https://github.com/radxa/overlays
  hardware.deviceTree = {
    enable = true;
    filter = "*radxa-zero.dtb";
    overlays = [
      {
        name = "uart-on-ttyAML0";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "radxa,zero", "amlogic,g12a";

            fragment@0 {
              target = <&uart_AO>;
              __overlay__ {
                status = "okay";
                pinctrl-0 = <&uart_ao_a_pins>;
                pinctrl-names = "default";
              };
            };
          };
        '';
      }
    ];
  };

  # Disabling the whole `profiles/base.nix` module, which is responsible
  # for adding ZFS and a bunch of other unnecessary programs:
  disabledModules = [
    "profiles/base.nix"
  ];

  # Sensible on a Radxa Zero, RAM is sparse.
  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };

  services.openssh = {
    settings = {
      PasswordAuthentication = true;
      AllowUsers = [
        "root"
      ];
    };
  };

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      ssh-pubkeys.obsidian.sidharta
      ssh-pubkeys.phone
      ssh-pubkeys.graphite.sidharta
      ssh-pubkeys.basalt.sidharta
      ssh-pubkeys.vivianite.sidharta
    ];
  };
  users.users.sidharta = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$gBDB9SKOqnh3cnPYEaxgj0$HCawgsRBrhcXvjvg8cSytRYtlExK/yaj219Fm8J7Jx3";
    openssh.authorizedKeys.keys = [
      ssh-pubkeys.obsidian.sidharta
      ssh-pubkeys.phone
      ssh-pubkeys.graphite.sidharta
      ssh-pubkeys.basalt.sidharta
      ssh-pubkeys.vivianite.sidharta
    ];
  };

  networking = {
    hostName = "fixie";

    wireless = {
      enable = true;
      userControlled.enable = true;
      networks = {
        Hannah = {
          psk = "fffeee11";
        };
      };
    };

    firewall = {
      trustedInterfaces = [
        "wg0"
      ];
      allowedTCPPorts = [
        22
      ];
      allowedUDPPorts = [
      ];
    };
    wireguard = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    tcpdump
  ];
}
