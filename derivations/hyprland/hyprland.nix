{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.desktops.customHyprland;
in
{
  options = {
    desktops.customHyprland = {
      enable = lib.mkEnableOption "custom wayland environment";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;

    services.greetd = {
      settings = rec {
        initial_session =
          let
            systemctl = "${pkgs.systemd}/bin/systemctl";
            startup = pkgs.writeScript "startup" ''
              ${systemctl} --user import-environment PATH
              exec ${pkgs.uwsm}/bin/uwsm start hyprland
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
  };
}
