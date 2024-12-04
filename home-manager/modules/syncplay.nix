{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.services.syncplay;
  isTruthy = v: v != null && v != false && v != "";
in

{
  imports = [ ];
  options.services.syncplay = {
    enable = mkEnableOption "Enable syncplay";

    port = mkOption {
      type = types.port;
      description = "Port used by syncplay-server";
      default = 8999;
      apply = v: if isTruthy v then "--port ${toString v}" else "";
    };

    password = mkOption {
      description = "Server password";
      type = types.str;
      apply = v: if isTruthy v then "--password ${v}" else "";
      default = "";
    };

    isolateRooms = mkOption {
      description = "should rooms be isolated?";
      type = types.bool;
      default = false;
      apply = v: if isTruthy v then "--isolate-rooms" else "";
    };

    disableReady = mkOption {
      description = "disable readiness feature";
      type = types.bool;
      default = false;
      apply = v: if isTruthy v then "--disable-ready" else "";
    };

    disableChat = mkOption {
      description = "Should chat be disabled?";
      type = types.bool;
      default = false;
      apply = v: if isTruthy v then "--disable-chat" else "";
    };

    salt = mkOption {
      description = "random string used to generate managed room passwords";
      type = types.str;
      default = "";
      apply = v: if isTruthy v then "--salt ${v}" else "";
    };

    maxChatMessageLength = mkOption {
      description = "Maximum number of characters in a chat message";
      type = types.int;
      default = 150;
      apply = v: if isTruthy v then "--max-chat-message-length ${toString v}" else "";
    };

    maxUsernameLength = mkOption {
      description = "Maximum number of characters in a username";
      type = types.int;
      default = 16;
      apply = v: if isTruthy v then "--max-username-length ${toString v}" else "";
    };
  };
  config = mkIf cfg.enable {
    assertions = [ ];

    home.packages = [ pkgs.syncplay ];

    systemd.user.services.syncplay-server =
      let
        optionCommandLine = optionName: builtins.getAttr optionName cfg;

        commandLineOptions = concatMapStringsSep " " optionCommandLine [
          "port"
          "password"
          "isolateRooms"
          "disableReady"
          "disableChat"
          "salt"
          "maxChatMessageLength"
          "maxUsernameLength"
        ];
      in
      {
        Unit = {
          Description = "Syncplay server";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${pkgs.syncplay}/bin/syncplay-server ${commandLineOptions}";
        };
      };
  };
}
