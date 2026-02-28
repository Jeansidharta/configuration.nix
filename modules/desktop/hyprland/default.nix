{
  inputs,
  pkgs,
  config,
  ...
}:
{
  nixpkgs.overlays =
    let
      inherit (config.lib.overlay-helpers) mkUnstable;
    in
    [
      (mkUnstable "glaze")
      inputs.hyprland.overlays.default
    ];

  imports = [
    inputs.hyprland.nixosModules.default
  ];

  home-manager.users.sidharta.imports = [
    inputs.hyprland.homeManagerModules.default
    ./home-manager.nix
  ];

  programs.hyprland = {
    enable = true;
  };

  # home.sessionVariables = {
  # WAYLAND_DISPLAY = "wayland-1";
  # };

  services.greetd = {
    settings = rec {
      initial_session =
        let
          systemctl = "${pkgs.systemd}/bin/systemctl";
          startup = pkgs.writeScript "startup" ''
            ${systemctl} --user import-environment PATH
            exec ${pkgs.hyprland}/bin/start-hyprland
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
}