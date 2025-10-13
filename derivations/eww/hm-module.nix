self:
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.programs.ewwCustom;
  custom-eww = self.outputs.packages.${system}.default;
in
{
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
      default = custom-eww;
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
      ewwCmd = lib.getExe (
        cfg.package.override (base: {
          extra-variables = base.extra-variables // cfg.extraVariables;
          extra-files = base.extra-files // cfg.extraFiles;
        })
      );
      bashCmd = lib.getExe pkgs.bash;
    in
    mkIf cfg.enable {
      home.packages = [ cfg.package ];
      # xdg.configFile."eww".source = configDir;
      systemd.user.services.eww = mkIf cfg.systemdService {
        Unit = {
          Description = "Eww bar";
        };
        Install = {
          WantedBy = [ cfg.systemdTarget ];
        };
        Service = {
          ExecStart = "${bashCmd} -c \"${ewwCmd} daemon --no-daemonize\"";
          ExecStartPost =
            if cfg.startingOpenWindow != null then
              "${bashCmd} -c \"${ewwCmd} open --no-daemonize ${cfg.startingOpenWindow}\""
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
