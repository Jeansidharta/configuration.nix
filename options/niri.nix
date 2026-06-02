{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    literalExpression
    mkIf
    ;

  cfg = config.programs.niri;

  toKDL = lib.hm.generators.toKDL { };
  kdlConfigType =
    with types;
    nullOr (oneOf [
      path
      kdlType
      lines
    ]);

  kdlType =
    with types;
    let
      valueType = nullOr (oneOf [
        bool
        int
        float
        str
        path
        (attrsOf valueType)
        (listOf valueType)
      ]);
    in
    valueType;
in
{
  options.programs.niri = {
    enable = mkEnableOption "Niri configuration";
    package = lib.mkPackageOption pkgs "niri" { };
    settings = mkOption {
      type = kdlConfigType;
      default = { };
      description = ''
        Defines your config.kdl for Niri. Can either be a path pointing to config.kdl, a multi-line string or an attributes set representing a KDL configuration.
      '';
      example = literalExpression ''
        # TODO - make a cool example
      '';
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile."niri/config.kdl" =
      if builtins.isPath cfg.settings then
        { source = cfg.settings; }
      else
        {
          text = if builtins.isAttrs cfg.settings then toKDL cfg.settings else cfg.settings;
        };
  };
}
