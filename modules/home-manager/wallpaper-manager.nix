{
  config,
  lib,
  pkgs,
  main-user,
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
      default = "/home/${main-user}/wallpapers/live";
    };

    cache-dir = mkOption {
      type = types.str;
      description = "Where the program's cache will be stored";
      default = "/home/${main-user}/.local/state/wallpaper-manager";
    };

    package = mkOption {
      type = types.package;
      description = "The wallpaper manager package";
      default = pkgs.mypkgs.wallpaper-manager;
    };

    enableZshIntegration = mkEnableOption "Enable Zsh integration" // {
      default = true;
    };
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
