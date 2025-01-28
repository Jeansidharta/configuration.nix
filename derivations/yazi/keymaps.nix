{ pkgs, ... }:
let
  dragon = "${pkgs.xdragon}/bin/xdragon";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  git = "${pkgs.git}/bin/git";
in
{
  programs.yazi.keymap = {
    manager.prepend_keymap = [
      {
        on = "<C-n>";
        run = "shell '${dragon} -x -i -T \"$1\"'";
        desc = "Open drag-n-drop app";
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
        desc = "Copy file paths to clipboard";
      }
      {
        on = [
          "g"
          "r"
        ];
        run = ''
          	shell 'ya emit cd "$(${git} rev-parse --show-toplevel)"'
        '';
        desc = "Go to Git Root";
      }
      {
        on = [
          "g"
          "n"
        ];
        run = "cd /etc/nixos";
        desc = "Go to NixOS directory";
      }
      {
        on = "<C-p>";
        run = [
          "leave"
          "open"
          "enter"
        ];
        desc = "Open current directory";
      }
      {
        on = "T";
        run = "plugin max-preview";
        desc = "Maximize or restore preview";
      }
      {
        on = "<C-d>";
        run = "plugin diff";
        desc = "Diff the selected with the hovered file";
      }
    ];
  };
}
