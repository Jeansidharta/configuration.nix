{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib.types) attrsOf;
  json = pkgs.formats.json { };
  cfg = config.programs.dank-material-shell;
in
{
  options.programs.dank-material-shell = {
    settings = lib.mkOption {
      type = attrsOf json.type;
      description = ''
        Settings stored at $XDG_CONFIG/DankMaterialShell/settings.json
      '';
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile."DankMaterialShell/settings.json".source =
      json.generate "dank-material-shell-settings" cfg.settings;
  };
}
