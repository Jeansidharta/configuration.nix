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

    systemdTarget = lib.options.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      description = "What target the systemd service should be WantedBy";
      defaultText = "graphical-session.target";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.services.swww = mkIf cfg.systemdService {
      Unit = {
        Description = "swww wallpaper engine";
      };
      Install = {
        WantedBy = [ cfg.systemdTarget ];
      };
      Service = {
        ExecStart = "${swwwDaemonCmd}";
      };
    };
  };
}
