{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.weron;
  weron = "${cfg.package}/bin/weron";
in
{
  options.services.weron = {
    enable = lib.mkEnableOption "Weron";
    package = lib.mkPackageOption pkgs "weron" { };

    vpn-mode = lib.mkOption {
      type = lib.types.enum [
        "ethernet"
        "ip"
      ];
      description = "";
    };
    community = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "";
    };
    key = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "";
      default = null;
    };
    keyFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };
    password = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "";
      default = null;
    };
    passwordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };
    ips = lib.mkOption {
      type = with lib.types; nullOr (nonEmptyListOf nonEmptyStr);
      description = "";
      default = null;
    };
    mac = lib.mkOption {
      type = with lib.types; nullOr nonEmptyStr;
      description = "";
      default = null;
    };
    ice = lib.mkOption {
      type = with lib.types; nullOr (nonEmptyListOf nonEmptyStr);
      description = "";
      default = null;
    };
    extraArguments = lib.mkOption {
      type = lib.types.attrsOf lib.types.nonEmptyStr;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.key != null || cfg.keyFile != null;
        message = "You must provide either services.weron.key or services.weron.keyFile";
      }
      {
        assertion = cfg.key == null || cfg.keyFile == null;
        message = "services.weron.key and services.weron.keyFile are mutually exclusive.";
      }
      {
        assertion = cfg.password != null || cfg.passwordFile != null;
        message = "You must provide either services.weron.password or services.weron.passwordFile";
      }
      {
        assertion = cfg.password == null || cfg.passwordFile == null;
        message = "services.weron.password and services.weron.passwordFile are mutually exclusive.";
      }
    ]
    ++ (
      if cfg.vpn-mode == "ip" then
        [
          {
            assertion = cfg.ips != null;
            message = "If services.weron.vpn-mode is \"ip\", then services.weron.ips must be specified.";
          }
          {
            assertion = cfg.mac == null;
            message = "If services.weron.vpn-mode is \"ip\", then services.weron.mac must be null.";
          }
        ]
      else
        [
          {
            assertion = cfg.ips == null;
            message = "If services.weron.vpn-mode is \"ethernet\", then services.weron.ips must be null.";
          }
        ]
    );

    systemd.services.weron =
      let
        args =
          lib.mapAttrsToList
            (
              name: value:
              let
                opt = if builtins.stringLength name == 1 then "-${name}" else "--${name}";
              in
              if value == null then
                ""
              else if builtins.typeOf value == "boolean" then
                "${opt}"
              else
                "${opt} ${builtins.toString value}"
            )
            (
              cfg.extraArguments
              // {
                inherit (cfg)
                  community
                  key
                  password
                  mac
                  ;
                ips = if cfg.ips != null then lib.join "," cfg.ips else null;
                ice = if cfg.ice != null then lib.join "," cfg.ice else null;
              }
            );
        argsStr = lib.join " " args;
      in
      {
        description = "Weron";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = "${weron} vpn ${cfg.vpn-mode} ${argsStr}";
          Restart = "always";
          RestartSec = "10s";
        };
      };
  };
}
