{ pkgs, ... }:

{
  systemd.user.services = {
    eww-bar-selector =
      let
        path = pkgs.lib.strings.concatStringsSep ":" [
          "${pkgs.hyprland}/bin"
          "${pkgs.eww}/bin"
          "/bin"
        ];
      in
      {
        Unit = {
          Description = "Eww bar selector";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.mypkgs.eww-bar-selector}/bin/eww_bar_selector";
          ExecSearchPath = path;
        };
      };

  };
}
