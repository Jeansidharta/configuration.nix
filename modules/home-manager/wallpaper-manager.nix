{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.services.wallpaper-manager;
in

{
  imports = [ ];
  options.services.wallpaper-manager = {
    enable = mkEnableOption "Enable wallpaper-manager";

    wallpapers-dir = mkOption {
      type = types.str;
      description = "Directory containing the user's wallpapers";
      default = "~/wallpapers";
    };

    cache-dir = mkOption {
      type = types.str;
      description = "Where the program's cache will be stored";
      default = "~/.local/state/wallpaper-manager";
    };

    package = mkOption {
      type = types.package;
      description = "The wallpaper manager package";
    };

    enableZshIntegration = mkEnableOption "Enable Zsh integration";
  };

  config =
    let
      execCommand = "${cfg.package}/bin/wallpaper-manager";

    in
    mkIf cfg.enable {
      assertions = [ ];

      home.packages = [ cfg.package ];

      xdg.configFile."wallpaper-manager/config.toml".source =
        (pkgs.formats.toml { }).generate "wallpaper-manager-config"
          {
            wallpapers_dir = cfg.wallpapers-dir;
            cache_dir = cfg.cache-dir;
          };

      systemd.user.services.wallpaper-manager = {
        Unit = {
          Description = "Wallpaper manager";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = execCommand + " daemon";
        };
      };
    };
}
