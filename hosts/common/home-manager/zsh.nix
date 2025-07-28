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
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    # initExtra = ''
    # export NIX_BUILD_SHELL=${nix-zshell}
    # '';
  };
}
