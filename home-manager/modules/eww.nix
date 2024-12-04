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

    package = mkOption {
      type = types.package;
      default = pkgs.eww;
      defaultText = literalExpression "pkgs.eww";
      example = literalExpression "pkgs.eww";
      description = ''
        The eww package to install.
      '';
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
      envsub = pkgs.callPackage (
        {
          lib,
          fetchFromGitHub,
          rustPlatform,
        }:

        rustPlatform.buildRustPackage rec {
          pname = "envsub";
          version = "0.1.3";

          src = fetchFromGitHub {
            owner = "stephenc";
            repo = pname;
            rev = "605623d4224986e0028e2dec9055891c2c46bfd6";
            hash = "sha256-DYfGH/TnDTaG5799upg4HDNFiMYpkE64s2DNXJ+1NnE=";
          };

          cargoHash = "sha256-1b0nhfbk7g2XiplOeVB25VQV2E3Z7B9tqANYvhOO6AQ=";

          meta = {
            description = "substitutes the values of environment variables";
            homepage = "https://github.com/stephenc/envsub";
            license = lib.licenses.mit;
            maintainers = [ ];
          };
        }
      ) { };

      extraFiles = mapAttrs pkgs.writeText cfg.extraFiles;
      copyCommandExtraFiles = lib.concatMapStringsSep "\n" (
        file: "cp --no-preserve=mode ${file} $out/${file.name}"
      ) (attrValues extraFiles);
      configDir = pkgs.runCommand "eww-config" ({ } // cfg.extraVariables) ''
                cp -r --no-preserve=mode ${cfg.configDir} $out
                ${copyCommandExtraFiles}
        		find $out/ -type f -exec bash -c "cat {} | ${envsub}/bin/envsub -p @ -s @ > {}.tmp && mv {}.tmp {}" \;
      '';
    in
    mkIf cfg.enable {
      home.packages = [ cfg.package ];
      xdg.configFile."eww".source = configDir;

      programs.bash.initExtra = mkIf cfg.enableBashIntegration ''
        if [[ $TERM != "dumb" ]]; then
           eval "$(${ewwCmd} shell-completions --shell bash)"
         fi
      '';

      programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
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
