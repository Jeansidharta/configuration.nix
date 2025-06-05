{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.programs.ewwCustom;
  ewwCmd = "${cfg.package}/bin/eww";

in
{
  meta.maintainers = [ hm.maintainers.mainrs ];

  options.programs.ewwCustom = {
    enable = mkEnableOption "eww";

    systemdService = mkEnableOption "Wether to start with a systemd service" // {
      default = false;
    };

    systemdTarget = lib.options.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      description = "What target the systemd service should be WantedBy";
      defaultText = "graphical-session.target";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.eww;
      defaultText = literalExpression "pkgs.eww";
      example = literalExpression "pkgs.eww";
      description = ''
        The eww package to install.
      '';
    };

    startingOpenWindow = mkOption {
      type = types.str;
    };

    extraFiles = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    extraVariables = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    configDir = mkOption {
      type = types.path;
      example = literalExpression "./eww-config-dir";
      description = ''
        The directory that gets symlinked to
        {file}`$XDG_CONFIG_HOME/eww`.
      '';
    };

    enableBashIntegration = mkEnableOption "Bash integration" // {
      default = true;
    };

    enableZshIntegration = mkEnableOption "Zsh integration" // {
      default = true;
    };

    enableFishIntegration = mkEnableOption "Fish integration" // {
      default = true;
    };
  };

  config =
    with builtins;
    let
      extraFiles = mapAttrs pkgs.writeText cfg.extraFiles;
      copyCommandExtraFiles = lib.concatMapStringsSep "\n" (
        file: "cp --no-preserve=mode ${file} $out/${file.name}"
      ) (attrValues extraFiles);
      configDir = pkgs.runCommand "eww-config" ({ } // cfg.extraVariables) ''
        cp -r --no-preserve=mode ${cfg.configDir} $out
        ${copyCommandExtraFiles}
        find $out/ -type f -exec bash -c "cat {} | ${pkgs.mypkgs.envsub}/bin/envsub -p @ -s @ > {}.tmp && mv {}.tmp {}" \;
      '';
    in
    mkIf cfg.enable {
      home.packages = [ cfg.package ];
      xdg.configFile."eww".source = configDir;
      systemd.user.services.eww = mkIf cfg.systemdService {
        Unit = {
          Description = "Eww bar";
        };
        Install = {
          WantedBy = [ cfg.systemdTarget ];
        };
        Service = {
          ExecStart = "${ewwCmd} daemon --no-daemonize";
          ExecStartPost =
            if cfg.startingOpenWindow != null then
              "${ewwCmd} open --no-daemonize ${cfg.startingOpenWindow}"
            else
              "";
        };
      };

      programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
        if [[ $TERM != "dumb" ]]; then
           eval "$(${ewwCmd} shell-completions --shell bash)"
         fi
      '';

      programs.zsh.initContent = mkIf cfg.enableZshIntegration ''
        if [[ $TERM != "dumb" ]]; then
          eval "$(${ewwCmd} shell-completions --shell zsh)"
        fi
      '';

      programs.fish.interactiveShellInit = mkIf cfg.enableFishIntegration ''
        if test "$TERM" != "dumb"
          eval "$(${ewwCmd} shell-completions --shell fish)"
        end
      '';
    };
}
