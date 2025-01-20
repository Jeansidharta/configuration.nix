# Copied from https://github.com/nix-community/home-manager/blob/release-24.11/modules/programs/wpaperd.nix

# This is different from the module provided by home-manager
# as it provides a systemd service

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.wpaperd;
  tomlFormat = pkgs.formats.toml { };
  wpaperdCmd = "${cfg.package}/bin/wpaperd";
in
{
  meta.maintainers = [ hm.maintainers.Avimitin ];

  options.services.wpaperd = {
    enable = mkEnableOption "wpaperd";

    package = mkPackageOption pkgs "wpaperd" { };

    systemdService = mkEnableOption "Wether to start with a systemd service" // {
      default = false;
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      example = literalExpression ''
        {
          eDP-1 = {
            path = "/home/foo/Pictures/Wallpaper";
            apply-shadow = true;
          };
          DP-2 = {
            path = "/home/foo/Pictures/Anime";
            sorting = "descending";
          };
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/wpaperd/wallpaper.toml`.
        See <https://github.com/danyspin97/wpaperd#wallpaper-configuration>
        for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "wpaperd/wallpaper.toml" = mkIf (cfg.settings != { }) {
        source = tomlFormat.generate "wpaperd-wallpaper" cfg.settings;
      };
    };

    systemd.user.services.wpaperd = mkIf cfg.systemdService {
      Unit = {
        Description = "wpaperd wallpaper engine";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${wpaperdCmd}";
      };
    };
  };
}
