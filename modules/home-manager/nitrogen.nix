{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.services.nitrogen;
in

{
  imports = [ ];
  options.services.nitrogen = {
    enable = mkEnableOption "Enable nitrogen service";

    wallpapersDir = mkOption {
      description = "Directory containing your wallpapers";
      type = types.path;
    };
  };
  config = mkIf cfg.enable {
    assertions = [ ];

    home.packages = [ pkgs.nitrogen ];

    systemd.user.services.nitrogen-restore = {
      Unit = {
        Description = "Nitrogen restore wallpaper";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.nitrogen}/bin/nitrogen --restore";
        Type = "oneshot";
      };
    };
  };
}
