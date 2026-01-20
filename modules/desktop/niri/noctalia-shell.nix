# To sync settings with the GUI, run

# jq -s 'reduce .[] as $obj ({}; . * $obj)' ~/.config/noctalia/settings.json ~/.config/noctalia/gui-settings.json > /tmp/asd && nix eval --impure --expr "builtins.fromJSON (builtins.readFile /tmp/asd)" > ~/nixos/modules/desktop/niri/noctalia-settings.nix

{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  hm-module =
    { theme, ... }:
    {
      imports = [ inputs.noctalia-shell.outputs.homeModules.default ];

      programs.noctalia-shell = {
        enable = true;
        systemd.enable = true;
        settings = import ./noctalia-settings.nix;
        colors =
          let
            inherit (theme.colors)
              red
              cyan
              pink
              green
              orange
              blue
              gray
              light_gray
              dark_gray
              bg_dark
              ;
          in
          {
            # you must set ALL of these
            mError = red;
            mOnError = bg_dark;
            mOnPrimary = red;
            mOnSecondary = bg_dark;
            mOnSurface = cyan;
            mOnSurfaceVariant = pink;
            mOnTertiary = bg_dark;
            mOnHover = pink;
            mOutline = gray;
            mPrimary = cyan;
            mSecondary = pink;
            mShadow = "#000000";
            mSurface = bg_dark;
            mHover = gray;
            mSurfaceVariant = bg_dark;
            mTertiary = orange;
          };
      };
    };
in
{
  imports = [ inputs.noctalia-shell.outputs.nixosModules.default ];

  nixpkgs.overlays = [ inputs.noctalia-shell.outputs.overlays.default ];

  home-manager.users.sidharta.imports = [ hm-module ];

  services.auto-cpufreq.enable = true;
  services.upower = {
    enable = true;
  };
}
