{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    typeOf
    ;
  inherit (lib.types)
    attrsOf
    nullOr
    oneOf
    int
    str
    ;

  cfg = config.programs.nchat;
  keyValueFormat = pkgs.formats.keyValue { };
  formatType = attrsOf (
    nullOr (oneOf [
      int
      str
    ])
  );
in
{
  options.programs.nchat = {
    enable = mkEnableOption "nchat";

    package = mkPackageOption pkgs "nchat" { };

    settings-app = mkOption {
      type = formatType;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/nchat/app.conf`.
      '';
    };

    settings-ui = mkOption {
      type = formatType;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/nchat/ui.conf`.
      '';
    };

    settings-key = mkOption {
      type = formatType;
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/nchat/key.conf`.
      '';
    };
    settings-color = mkOption {
      type = oneOf [
        formatType
        str
      ];
      default = { };
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/nchat/color.conf`.
        If a string is provided, use as a theme instead
      '';
    };
  };
  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile =
      let
        mkConfig = config-name: setting: {
          source = keyValueFormat.generate "nchat-${config-name}" setting;
        };
      in
      {
        "nchat/app.conf" = mkConfig "app-config" cfg.settings-app;
        "nchat/ui.conf" = mkConfig "ui-config" cfg.settings-ui;
        "nchat/key.conf" = mkConfig "key-config" cfg.settings-key;
        "nchat/color.conf" =
          if (typeOf cfg.settings-color) == "string" then
            { source = "${cfg.package}/share/nchat/themes/${cfg.settings-color}/color.conf"; }
          else
            mkConfig "color-config" cfg.settings-color;
      };
  };
}
