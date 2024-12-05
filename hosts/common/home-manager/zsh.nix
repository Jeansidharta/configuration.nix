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
  enable = true;
  autosuggestion.enable = true;
  shellAliases = {
    "hm" = "home-manager";
    "ses" = "systemctl --user";
    "vim" = "nvim";
    "vi" = "nvim";
    "ns" = "nix-shell";
    "nsb" = "env -u NIX_BUILD_SHELL nix-shell";
    "ne" = "nix-env";
    "nb" = "nix-build";
    "ls" = "eza";
    "xclip" = "xclip -selection clipboard";

    "nvim-test" = "nix run /home/sidharta/.config/home-manager/derivations/neovim --no-net -- ";
  };
  # initExtra = ''
  # export NIX_BUILD_SHELL=${nix-zshell}
  # '';
}
