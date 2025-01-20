{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.waypaper;
  iniFormat = pkgs.formats.ini { };
in
{
  options.programs.waypaper = {
    enable = mkEnableOption "waypaper";

    package = mkPackageOption pkgs "waypaper" { };

    settings = mkOption {
      type =
        with lib.types;
        (attrsOf (
          nullOr (oneOf [
            bool
            int
            float
            str
          ])
        ));
      default = { };
      example = literalExpression ''
        {
          folder = "/home/user/wallpapers";
          sort = "name";
          wallpaper = "/home/user/wallpapers/wallpaper.jpg";
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/waypaper/config.ini`.
        See <https://anufrievroman.gitbook.io/waypaper/configuration>
        for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "waypaper/config.ini" = mkIf (cfg.settings != { }) {
        source = iniFormat.generate "waypaper-config" { Settings = cfg.settings; };
      };
    };
  };
}
