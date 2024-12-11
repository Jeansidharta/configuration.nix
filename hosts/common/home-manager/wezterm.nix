{ pkgs, ... }:
{
  enable = true;
  enableZshIntegration = true;
  extraConfig = builtins.readFile ./wezterm/wezterm.lua;
}
