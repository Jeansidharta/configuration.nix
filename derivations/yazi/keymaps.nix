{ pkgs, ... }:
let
  dragon = "${pkgs.xdragon}/bin/xdragon";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  git = "${pkgs.git}/bin/git";
in
{
  programs.yazi.keymap = {
    input.keymap = [
    ];
    manager.keymap = [
      {
        on = "<C-n>";
        run = "shell '${dragon} -x -i -T \"$1\"'";
      }
      {
        on = "!";
        run = "shell \"$SHELL\" --block";
        desc = "Open shell here";
      }
      {
        on = "Y";
        run = ''
          	shell 'for path in "$@"; do echo "file://$path"; done | ${wl-copy} -t text/uri-list'
        '';
      }
      {
        on = [
          "g"
          "r"
        ];
        run = ''
          	shell 'ya emit cd "$(${git} rev-parse --show-toplevel)"'
        '';
      }
    ];
  };
}
