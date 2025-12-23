{ config, pkgs, ... }:
{
  hardware.graphics.enable = true;
  services.udisks2.enable = true;

  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  users.users.sidharta = {
    extraGroups = [
      "dialout"
      "pipewire"
    ];
    packages = [ pkgs.home-manager ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.udev.extraRules = ''
    # For developing with a Raspberry PI
    ATTRS{vendor}=="RPI", ATTRS{model}=="RP2", MODE="0666"

    # Serial port of my keyboard for Stenography
    ATTRS{product}=="stenidol", SYMLINK+="stenidol", OWNER="sidharta"

    ATTRS{serial}=="BZEEk13AL19", MODE="0666"
    ATTR{manufacturer}=="Stenograph", MODE="0666"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  programs.niri.enable = true;
  niri-flake.cache.enable = false;
  programs.niri.package = pkgs.niri-unstable;
  services.greetd = {
    settings = rec {
      initial_session =
        let
          systemctl = "${pkgs.systemd}/bin/systemctl";
          startup = pkgs.writeScript "startup" ''
            ${systemctl} --user import-environment PATH
            exec ${pkgs.niri}/bin/niri-session
          '';
        in
        {
          user = "sidharta";
          command = startup;
        };
      default_session = initial_session;
    };
    enable = true;
  };
  programs.nix-ld.enable = true;
}
