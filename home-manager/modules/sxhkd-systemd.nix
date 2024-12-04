{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.sxhkd-systemd;

  keybindingsStr = concatStringsSep "\n" (
    mapAttrsToList (
      hotkey: command:
      optionalString (command != null) ''
        ${hotkey}
          ${command}
      ''
    ) cfg.keybindings
  );

in
{
  imports = [
    (mkRemovedOptionModule [
      "services"
      "sxhkd-systemd"
      "extraPath"
    ] "This option is no longer needed and can be removed.")
  ];

  options.services.sxhkd-systemd = {
    enable = mkEnableOption "simple X hotkey daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.sxhkd;
      defaultText = "pkgs.sxhkd";
      description = "Package containing the {command}`sxhkd` executable.";
    };

    extraOptions = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Command line arguments to invoke {command}`sxhkd` with.";
      example = literalExpression ''[ "-m 1" ]'';
    };

    keybindings = mkOption {
      type = types.attrsOf (
        types.nullOr (
          types.oneOf [
            types.str
            types.path
          ]
        )
      );
      default = { };
      description = "An attribute set that assigns hotkeys to commands.";
      example = literalExpression ''
        {
          "super + shift + {r,c}" = "i3-msg {restart,reload}";
          "super + {s,w}"         = "i3-msg {stacking,tabbed}";
          "super + F1"            = pkgs.writeShellScript "script" "echo $USER";
        }
      '';
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = "Additional configuration to add.";
      example = literalExpression ''
        super + {_,shift +} {1-9,0}
          i3-msg {workspace,move container to workspace} {1-10}
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.sxhkd-systemd" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."sxhkd/sxhkdrc".text = concatStringsSep "\n" [
      keybindingsStr
      cfg.extraConfig
    ];

    systemd.user.services.sxhkd =
      let
        sxhkdCommand = "${cfg.package}/bin/sxhkd ${toString cfg.extraOptions}";
      in
      {
        Unit = {
          Description = "Sxhkd hotkey daemon";
          Documentation = "man:sxhkd(1)";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${sxhkdCommand}";
          ExecReload = "kill -SIGUSR1 $MAINPID";
          KillMode = "process";
          Restart = "always";
          RestartSec = "0.5";
        };
      };
  };
}
