{ lib, config, ... }:
let
  cfg = config.host-data;
in
{
  options.host-data = {
    profile = lib.mkOption {
      default = null;
      type = lib.types.nullOr (
        lib.types.enum [
          "laptop"
          "desktop"
          "headless"
        ]
      );
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.profile != null;
        message = "You must provide a host-data.kind value";
      }
    ];
  };
}
