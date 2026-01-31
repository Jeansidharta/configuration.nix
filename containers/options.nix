{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkOption;
  inherit (lib.options) mkEnableOption;
  inherit (lib.types) singleLineStr attrOf submodule;

  cfg = config.services.containers-mesh;

  container-submodule =
    { ... }:
    {
      options = {
        key = mkOption {
          type = singleLineStr;
          description = "The key to use on the wireguard interface";
        };
        name = mkOption {
          type = singleLineStr;
          description = "The name of the container";
        };
        ip = mkOption {
          type = singleLineStr;
          description = "The IP of the container";
        };
      };
    };
in
{
  options.services.containers-mesh = {
    enable = mkEnableOption "Enable containers mesh";

    containers = mkOption {
      type = attrOf (submodule container-submodule);
    };
  };
  config = {
    assertions = [ ];

    systemd.services."container@${container-name}" = {
      unitConfig = {
        BindsTo = [ "${wireguard-name}.service" ];
        After = [ "${wireguard-name}.service" ];
      };
    };

    systemd.services.${wireguard-name} = {
      unitConfig = {
        Description = "Wireguard's instance for the ${container-name} container";
      };
      serviceConfig =
        let
          bash = lib.getExe pkgs.bash;
          ip = lib.getExe' pkgs.iproute2 "ip";
        in
        {
          Type = "oneshot";
          NotifyAccess = "all";
          ExecStart = "${bash} ${pkgs.writeScript "init-interface" ''
            ${ip} link add ${wireguard-name} type wireguard
            ${wg} set ${wireguard-name} private-key ${pkgs.writeText "key" key}
          ''}";
          ExecStop = "${bash} ${pkgs.writeScript "stop-interface" ''
            ${ip} link delete ${wireguard-name} 
          ''}";
        };
    };

    containers.${container-name} = lib.mkMerge [
      {
        interfaces = [ wireguard-name ];
      }
      container-config
    ];
  };
}
