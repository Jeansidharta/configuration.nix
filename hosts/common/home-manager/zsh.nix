{ pkgs, ... }:
let
  # A thin wrapper for nix-shell to use zsh instead of bash
  # Script copied from https://ianthehenry.com/posts/how-to-learn-nix/nix-zshell/
  nix-zshell =
    with pkgs;
    (writeScript "nix-zshell" ''
      if [[ "$1" = "--rcfile" ]]; then
        rcfile="$2"
        source "$rcfile"

        exec ${zsh}/bin/zsh --emulate zsh
      else
        exec ${bashInteractive}/bin/bash "$@"
      fi
    '');

  replace = pkgs.writeScript "replace" ''
    if [[ -e "$1.old" ]]; then
      rm -rfi "$1"
      mv "$1.old" "$1"
    else
      mv "$1" "$1.old"
      cp --dereference --no-preserve=mode -r "$1.old" "$1"
    fi
  '';
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    shellAliases = {
      "ses" = "systemctl --user";
      "vim" = "nvim";
      "vi" = "nvim";
      "ls" = "eza";

      "cdtmp" = "cd $(mktemp --dir)";

      "nvim-test" = "nix run /home/sidharta/projects/neovim-flake --no-net -- ";
      "replace" = "${replace}";
    };
    # initExtra = ''
    # export NIX_BUILD_SHELL=${nix-zshell}
    # '';
  };
}
