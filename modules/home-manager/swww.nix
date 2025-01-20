{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.swww;
  swwwDaemonCmd = "${cfg.package}/bin/swww-daemon";
in
{
  options.services.swww = {
    enable = mkEnableOption "swww";

    package = mkPackageOption pkgs "swww" { };

    systemdService = mkEnableOption "Wether to start with a systemd service" // {
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.swww = mkIf cfg.systemdService {
      Unit = {
        Description = "swww wallpaper engine";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${swwwDaemonCmd}";
      };
    };
  };
}
