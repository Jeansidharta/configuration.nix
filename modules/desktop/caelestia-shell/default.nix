{ inputs, ... }:
let
  hm-module =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [ inputs.caelestia-shell.outputs.homeManagerModules.default ];
      programs.caelestia = {
        enable = true;
        package = (
          inputs.caelestia-shell.outputs.packages.${pkgs.stdenv.hostPlatform.system}.with-cli.override
            (prev: {
              hyprland = pkgs.hello;
            })
        );
        systemd = {
          enable = true;
        };
        settings = {
          general = {
            apps = {
              terminal = [ (lib.getExe pkgs.wezterm) ];
            };
          };
          bar = {
            entries = [
              {
                id = "logo";
                enabled = true;
              }
              {
                id = "tray";
                enabled = true;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "activeWindow";
                enabled = true;
              }
              {
                id = "spacer";
                enabled = true;
              }
              {
                id = "clock";
                enabled = true;
              }
              {
                id = "statusIcons";
                enabled = true;
              }
              {
                id = "power";
                enabled = true;
              }
            ];
          };
          paths.wallpaperDir = "/home/sidharta/wallpapers/static";
        };
        cli.enable = true;
      };

      programs.niri.settings.binds =
        let
          cs = lib.geExe' pkgs.caelestia-shell "caelestia";
        in
        {
          # "Super+Space".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "spotlight"
          #   "toggle"
          # ];
          # "Super+v".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "clipboard"
          #   "toggle"
          # ];
          # "XF86AudioRaiseVolume".action.spawn = [
          #   cs
          #   "shell"
          #   "mpris"
          #   "audio"
          #   "increment"
          #   "5"
          # ];
          # "XF86AudioLowerVolume".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "audio"
          #   "decrement"
          #   "5"
          # ];
          # "XF86AudioMute".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "audio"
          #   "mute"
          # ];
          # "XF86AudioNext".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "mpris"
          #   "next"
          # ];
          # "XF86AudioPlay".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "mpris"
          #   "playPause"
          # ];
          # "XF86AudioPrev".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "mpris"
          #   "previous"
          # ];
          # "Super+s".action.spawn = [
          #   cs
          #   "ipc"
          #   "call"
          #   "lock"
          #   "lock"
          # ];
        };
    };
in
{
  home-manager.users.sidharta.imports = [ hm-module ];
  nixpkgs.overlays = [
    (final: prev: { caelestia-shell = inputs.caelestia-shell.outputs.packages.with-cli; })
  ];
}
