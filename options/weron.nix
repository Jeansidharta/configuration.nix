{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.weron;
  weron = "${cfg.package}/bin/weron";
  bash = lib.getExe pkgs.bash;

  base-vpn-module-options = {
    enable = lib.mkEnableOption "Enable service" // {
      default = true;
    };
    community = lib.mkOption {
      type = lib.types.nonEmptyStr;
      description = "ID of community to join";
      example = "\"my-community\"";
    };
    key = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Encryption key for community";
      example = "\"my-very-secure-key\"";
      default = null;
    };
    keyFile = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Encryption file key for community";
      example = "/run/agenix/key";
      default = null;
    };
    password = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Password for community";
      example = "\"my-very-secure-password\"";
      default = null;
    };
    passwordFile = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Password file for community";
      example = "/run/agenix/passwd";
      default = null;
    };
    ice = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "List of STUN servers (in format stun:host:port) and TURN servers to use (in format username:credential@turn:host:port) (i.e. username:credential@turn:global.turn.twilio.com:3478?transport=tcp) ";
      defaultText = "[ \"stun:stun.l.google.com:19302\" ]";
      default = [ ];
    };
  };

  vpn-ip-module = lib.types.submodule (
    { config, lib, ... }:
    {
      # freeformType = with lib.types; attrsOf singleLineStr;
      options = base-vpn-module-options // {
        ips = lib.mkOption {
          type = with lib.types; nonEmptyListOf nonEmptyStr;
          description = "List of IP networks to claim an IP address from and and give to the TUN device (on macOS, IPv4 networks are ignored)";
          example = "2001:db8::1/32,192.168.2.0/24";
        };
      };
    }
  );

  vpn-ethernet-module = lib.types.submodule (
    { lib, config, ... }:
    {
      freeformType = with lib.types; attrsOf singleLineStr;
      options = base-vpn-module-options;
    }
  );
in
{
  options.services.weron = {
    enable = lib.mkEnableOption "Enable service";
    package = lib.mkPackageOption pkgs "weron" { };

    vpn-ip = lib.mkOption {
      type = lib.types.attrsOf vpn-ip-module;
      default = { };
    };

    vpn-ethernet = lib.mkOption {
      type = lib.types.attrsOf vpn-ethernet-module;
      default = { };
    };
  };

  config =
    let
      formatterAttrsToArgs =
        attrs:
        let
          inherit (builtins) stringLength typeOf;
          inherit (lib) escapeShellArg mapAttrsToList join;
          kvToArg =
            name: value:
            let
              isEmpty = str: str == null || (typeOf str == "string" && stringLength str == 0);
              opt = escapeShellArg (if stringLength name == 1 then "-${name}" else "--${name}");
            in
            if isEmpty name || isEmpty value then
              ""
            else if typeOf value == "boolean" then
              if value then "${opt}" else ""
            else
              "${opt} ${escapeShellArg value}";
        in
        join " " (mapAttrsToList kvToArg attrs);

      base-systemd-service = exec-start: enable: {
        description = "Weron";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          ExecStart = exec-start;
          Restart = "always";
          RestartSec = "10s";
        };
      };
      attrOrFile =
        attrName: module:
        if module.${attrName} != null then module.${attrName} else "$(cat ${module.${attrName + "File"}})";
      vpn-ip-services = (
        lib.mapAttrs' (name: module: {
          name = "weron-vpn-ip@${name}";
          value =
            let
              args =
                formatterAttrsToArgs (
                  (lib.removeAttrs module [
                    "enable"
                    "passwordFile"
                    "keyFile"
                  ])
                  // {
                    ips = lib.join "," module.ips;
                    ice = lib.join "," module.ice;
                  }
                )
                + " --key \"${attrOrFile "key" module}\""
                + " --password \"${attrOrFile "password" module}\"";
              startScript = pkgs.writeScript "weron-ip-${name}-execstart" ''
                #!${bash}
                exec ${weron} vpn ip ${args}
              '';
            in
            base-systemd-service "${startScript}" module.enable;
        }) cfg.vpn-ip
      );

      vpn-ethernet-services = (
        lib.mapAttrs' (name: module: {
          name = "weron-vpn-ethernet@${name}";
          value =
            let
              args =
                formatterAttrsToArgs (
                  (lib.removeAttrs module [
                    "enable"
                    "passwordFile"
                    "keyFile"
                  ])
                  // {
                    ice = lib.join "," module.ice;
                  }
                )
                + " --key \"${attrOrFile "key" module}\""
                + " --password \"${attrOrFile "password" module}\"";
              startScript = pkgs.writeScript "weron-ethernet-${name}-execstart" ''
                #!${bash}
                exec ${weron} vpn ethernet ${args}
              '';
            in
            base-systemd-service "${startScript}" module.enable;
        }) cfg.vpn-ethernet
      );

      ip-bins = lib.mapAttrsToList (
        name: module:
        pkgs.writeScriptBin "weron-ip-${name}" ''
          #!${bash}
          exec ${weron} --community '${module.community}' --key '${attrOrFile "key" module}' --password '${attrOrFile "password" module}'
        ''
      ) cfg.vpn-ip;

      ethernet-bins = lib.mapAttrsToList (
        name: module:
        pkgs.writeScriptBin "weron-ethernet-${name}" ''
          #!${bash}
          ${weron} --community '${module.community}' --key '${attrOrFile "key" module}' --password '${attrOrFile "password" module}'
        ''
      ) cfg.vpn-ethernet;

      assertModule = name: module: [
        {
          assertion = module.password != null || module.passwordFile != null;
          message = "You must provide either services.weron.vpn-ip-module.${name}.password or services.weron.vpn-ip-module.${name}.passwordFile";
        }
        {
          assertion = module.key != null || module.keyFile != null;
          message = "You must provide either services.weron.vpn-ip-module.${name}.key or services.weron.vpn-ip-module.${name}.keyFile";
        }
        {
          assertion = module.password == null || module.passwordFile == null;
          message = "services.weron.vpn-ip-module.${name}.password is mutually exclusive with services.weron.vpn-ip-module.${name}.passwordFile";
        }
        {
          assertion = module.key == null || module.keyFile == null;
          message = "services.weron.vpn-ip-module.${name}.key is mutually exclusive with services.weron.vpn-ip-module.${name}.keyFile";
        }
      ];
    in
    lib.mkIf cfg.enable {
      assertions = lib.flatten (
        (lib.mapAttrsToList assertModule cfg.vpn-ethernet) ++ (lib.mapAttrsToList assertModule cfg.vpn-ip)
      );
      systemd.services = vpn-ip-services // vpn-ethernet-services;
      environment.systemPackages = [ cfg.package ] ++ ip-bins ++ ethernet-bins;
    };
}
