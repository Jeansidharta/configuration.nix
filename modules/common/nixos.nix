{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  reboot-script = pkgs.writeScriptBin "rrr" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl reboot "$@"
  '';

  sleep-script = pkgs.writeScriptBin "zzz" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl suspend "$@"
  '';

  shutdown-script = pkgs.writeScriptBin "xxx" ''
    #!/usr/bin/env bash

    sudo ${pkgs.systemd}/bin/systemctl poweroff "$@"
  '';
in
{
  imports = [
    ("${inputs.disko}/module.nix")
    ./overlays.nix
    ../../options/host-data.nix
  ];
  home-manager.extraSpecialArgs = {
    inherit (inputs.theme.outputs) theme;
    inherit inputs;
  };

  lib.overlay-helpers = {
    /**
      Pulls the package from nixpkgs-unstable instead of stable.
    */
    mkUnstable =
      pkg-name:
      (final: prev: {
        ${pkg-name} = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.${pkg-name};
      });
    overlay-flake = name: final: prev: {
      ${name} = inputs.${name}.packages.${prev.stdenv.hostPlatform.system}.default;
    };
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.extraConfig = ''
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl suspend
    sidharta ALL= NOPASSWD: ${sleep-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl poweroff
    sidharta ALL= NOPASSWD: ${shutdown-script}
    sidharta ALL= NOPASSWD: ${pkgs.systemd}/bin/systemctl reboot
    sidharta ALL= NOPASSWD: ${reboot-script}
  '';

  networking.hosts = {
    "::1" = [
      "ip6-localhost"
      "ip6-loopback"
    ];
    "fe00::0" = [ "ip6-localnet" ];
    "ff00::0" = [ "ip6-mcastprefix" ];
    "ff02::1" = [ "ip6-allnodes" ];
    "ff02::2" = [ "ip6-allrouters" ];
  };

  services.resolved.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.timesyncd.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;
    settings = {
      PermitTunnel = true;
      PasswordAuthentication = lib.mkDefault false;
      UseDns = false;
      AllowUsers = [
        "sidharta"
      ];
    };
  };

  users.mutableUsers = false;
  users.defaultUserShell = pkgs.zsh;

  users.users.sidharta = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$gBDB9SKOqnh3cnPYEaxgj0$HCawgsRBrhcXvjvg8cSytRYtlExK/yaj219Fm8J7Jx3";
  };

  services.nixseparatedebuginfod2.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    git
    wireguard-tools
    zsh
    tmux
    busybox
    jq
    iw
    bintools
    file
    sleep-script
    shutdown-script
    reboot-script
    nftables # firewall frontend

    btop # Process manager
    ripgrep
    jq # CLI tool for filtering Json data
    moreutils # A collection of tools to improve bash scripting
    tmsu # File tagging tool
    socat # Tool for connecting/debugging read/write interfaces
    unar # Unzip tool
    darkhttpd # Very simple http server
    sqlite-diagram
    neovim

    ######## TOOLBOX FOR DEBUGGING ########
    conntrack-tools # Show connections tracked by the kernel
    dnsutils # DNS testing tools
    pciutils # lspci command to show current pci devices
    powertop # Show power usage
    hdparm # Hard drive config manager
    dmidecode # Show DMI configuration, if available
    lshw # Show hardware config
    # tcpdump # Dump tcp connections
    termshark # wireshark on the terminal
    ethtool # Manage ethernet drivers
    strace # Show all syscalls made by application
    ltrace # Show binary library calls
    patchelf # Quickly modify ELF binaries
    traceroute # Shows the route to a destination on the internet
    nmap # map network
    usbutils # Tool for manipulating USB
    gdb
    bmon
    sshfs

    (pkgs.writeScriptBin "replace" ''
      if [[ -e "$1.old" ]]; then
        rm -rfi "$1"
        mv "$1.old" "$1"
      else
        mv "$1" "$1.old"
        cp --dereference --no-preserve=mode -r "$1.old" "$1"
      fi
    '')
    (pkgs.writeScriptBin "random-mac" ''
      #!/usr/bin/env bash

      echo 00-60-2F-$[RANDOM%10]$[RANDOM%10]-$[RANDOM%10]$[RANDOM%10]-$[RANDOM%10]$[RANDOM%10]
    '')
    (pkgs.writeScriptBin "canonical" ''
      #!/usr/bin/env bash

      path="$(which "$1")"
      path="$(readlink -f "$path")"

      echo "$path"
    '')
    (pkgs.writeScriptBin "root-derivation" ''
      #!/usr/bin/env bash

      path="$(which "$1")"
      path="$(readlink -f "$path")"
      path="$(dirname "$path")"

      echo "$path"
    '')
    (pkgs.writeScriptBin "rmnix" ''
      #!/usr/bin/env bash

      link=$(readlink "$1")

      if [ $? == 0 ]; then
      	rm "$1"
      	nix store delete "$link"
      fi
    '')
    (pkgs.writeScriptBin "nom-callpackage" ''
      exec nom build --impure --expr "with import <nixpkgs> {}; callPackage (import $1) {}" "$@"
    '')
    (pkgs.writeScriptBin "ndev" "
      exec nix develop . -c zsh
    ")

    (pkgs.writeScriptBin "jtl" ''
      exec journalctl "$@"
    '')
    (pkgs.writeScriptBin "jtu" ''
      exec journalctl --user "$@"
    '')
  ];

  networking.wireguard.enable = true;
  nix = {
    package = pkgs.nixVersions.latest;
    registry = {
      # Pin the registry's nixpkgs ref to the system's nixpkgs instance
      nixpkgs.to = {
        type = "path";
        path = inputs.nixpkgs-stable.outPath;
        narHash = inputs.nixpkgs-stable.narHash;
      };
    };
    settings = {
      substituters = [ ];
      trusted-public-keys = [ ];
      max-jobs = 4;

      warn-dirty = false;
      allowed-users = [ "@wheel" ];
      trusted-users = [
        "root"
        "sidharta"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
        "dynamic-derivations"
        "ca-derivations"
      ];
    };
  };
  services.speechd.enable = false;
  programs = {
    # neovim = {
    #   enable = true;
    #   package = inputs.neovim-with-plugins.packages.${pkgs.stdenv.hostPlatform.system}.default;
    #   vimAlias = true;
    #   defaultEditor = true;
    # };
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
    ];
    allowedUDPPorts = [ 4789 ];
  };

  system.stateVersion = "24.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
