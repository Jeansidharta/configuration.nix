{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [
    inputs.niri.overlays.niri
  ];
  imports = [
    ./dank-material-shell.nix
    # ./caelestia-shell.nix
    # ./eww.nix
  ];
  home-manager.users.sidharta.imports = [
    ./home-manager.nix
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

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
}
