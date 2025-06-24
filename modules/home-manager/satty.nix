{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.satty;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.satty = {
    enable = mkEnableOption "satty";

    package = mkPackageOption pkgs "satty" { };

    config = mkOption {
      type = tomlFormat.type;
      default = { };
      example = literalExpression ''
        {
          general = {
            fullscreen = true;
            initial-tool = "brush";
          };
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/satty/config.toml`.
        See <https://github.com/gabm/Satty?tab=readme-ov-file#configuration-file>
        for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "satty/config.toml" = mkIf (cfg.config != { }) {
        source = tomlFormat.generate "config.toml" cfg.config;
      };
    };
  };
}
