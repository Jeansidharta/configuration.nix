{
  lib,
  pkgs,
  config,
  ...
}:
{

  programs.niri.settings.binds =
    let
      niri = lib.getExe pkgs.niri;
      xargs = "${pkgs.findutils}/bin/xargs";
      jq = lib.getExe pkgs.jq;
      wezterm = lib.getExe pkgs.wezterm;
      leaderKey = "Super";
      wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
      grim = lib.getExe pkgs.grim;
      drawy = lib.getExe pkgs.drawy;
      satty = lib.getExe pkgs.satty;
      wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
      vipe = "${pkgs.moreutils}/bin/vipe";
      neovim = "${pkgs.neovim}/bin/nvim";
      mpc = lib.getExe pkgs.mpc;

      modifyClipboard = pkgs.writeScript "write-script" ''
        ${wezterm} start -- bash -c "export EDITOR=${neovim} ; ${wl-paste} | ${vipe} | ${wl-copy} && exit"
      '';
      paste-qrcode = (
        let
          qrencode = lib.getExe pkgs.qrencode;
          mpv = lib.getExe pkgs.mpv;
        in
        pkgs.writeScript "qrcode" ''
          IMAGE_FILE=$(mktemp qrcode-XXX)
          ${wl-paste} | ${xargs} ${qrencode} -o "$IMAGE_FILE" && ${mpv} -f -s f "$IMAGE_FILE"
          rm -f "$IMAGE_FILE"
        ''
      );
    in
    {
      "Super+e" = {
        spawn-sh = "${wl-paste} | ${satty} --filename - --initial-tool crop --output-filename \"/home/sidharta/screenshots-niri/%Y-%m-%d_%H:%M:%S.png\" --save-after-copy";
      };
      "Print" = {
        spawn = [
          "${niri}"
          "msg"
          "action"
          "screenshot-screen"
        ];
      };
      "Shift+Print" = {
        spawn = [
          "${niri}"
          "msg"
          "action"
          "screenshot-window"
        ];
      };
      "Shift+XF86AudioLowerVolume" = {
        spawn = [
          "${mpc}"
          "volume +10"
        ];
      };
      "Shift+XF86AudioNext" = {
        spawn = [
          "${mpc}"
          "next"
        ];
      };
      "Shift+XF86AudioPlay" = {
        spawn = [
          "${mpc}"
          "toggle"
        ];
      };
      "Shift+XF86AudioPrev" = {
        spawn = [
          "${mpc}"
          "prev"
        ];
      };
      "Shift+XF86AudioRaiseVolume" = {
        spawn = [
          "${mpc}"
          "volume"
          "+10"
        ];
      };
      "Super+d" = {
        spawn = [
          "${drawy}"
          "default-board"
        ];
      };
      "Super+1" = {
        focus-workspace = "browser";
      };
      "Super+2" = {
        focus-workspace = "2";
      };
      "Super+3" = {
        focus-workspace = "3";
      };
      "Super+4" = {
        focus-workspace = "4";
      };
      "Super+5" = {
        focus-workspace = "5";
      };
      "Super+6" = {
        focus-workspace = "6";
      };
      "Super+7" = {
        focus-workspace = "communication";
      };
      "Super+8" = {
        focus-workspace = "gaming";
      };
      "Super+9" = {
        focus-workspace = "x";
      };
      "Super+Alt+1" = {
        focus-monitor = "HDMI-A-1";
      };
      "Super+Alt+2" = {
        focus-monitor = "DP-1";
      };
      "Super+Alt+Left" = {
        focus-monitor-left = { };
      };
      "Super+Alt+Right" = {
        focus-monitor-right = { };
      };
      "Super+Alt+Shift+1" = {
        move-window-to-monitor = "HDMI-A-1";
      };
      "Super+Alt+Shift+2" = {
        move-window-to-monitor = "DP-1";
      };
      "Super+Alt+Shift+Left" = {
        move-window-to-monitor-left = { };
      };
      "Super+Alt+Shift+Right" = {
        move-window-to-monitor-right = { };
      };
      "Super+Alt+b" = {
        set-dynamic-cast-monitor = { };
      };
      "Super+Ctrl+F1" = {
        set-window-height = "100%";
      };
      "Super+Ctrl+F10" = {
        set-window-height = "0%";
      };
      "Super+Ctrl+F2" = {
        set-window-height = "50%";
      };
      "Super+Ctrl+F3" = {
        set-window-height = "33%";
      };
      "Super+Ctrl+F4" = {
        set-window-height = "25%";
      };
      "Super+Ctrl+F5" = {
        set-window-height = "20%";
      };
      "Super+Ctrl+F6" = {
        set-window-height = "16.66%";
      };
      "Super+Ctrl+F7" = {
        set-window-height = "14.28%";
      };
      "Super+Ctrl+F8" = {
        set-window-height = "12.5%";
      };
      "Super+Ctrl+F9" = {
        set-window-height = "11.11%";
      };
      "Super+Ctrl+v" = {
        spawn = [ "${modifyClipboard}" ];
      };
      "Super+Down" = {
        focus-window-down = { };
      };
      "Super+End" = {
        focus-column-last = { };
      };
      "Super+F1" = {
        set-column-width = "100%";
      };
      "Super+F10" = {
        set-column-width = "0%";
      };
      "Super+F2" = {
        set-column-width = "50%";
      };
      "Super+F3" = {
        set-column-width = "33%";
      };
      "Super+F4" = {
        set-column-width = "25%";
      };
      "Super+F5" = {
        set-column-width = "20%";
      };
      "Super+F6" = {
        set-column-width = "16.66%";
      };
      "Super+F7" = {
        set-column-width = "14.28%";
      };
      "Super+F8" = {
        set-column-width = "12.5%";
      };
      "Super+F9" = {
        set-column-width = "11.11%";
      };
      "Super+Home" = {
        focus-column-first = { };
      };
      "Super+Left" = {
        focus-column-left = { };
      };
      "Super+Return" = {
        spawn = [ "${wezterm}" ];
      };
      "Super+Right" = {
        focus-column-right = { };
      };
      "Super+Shift+1" = {
        move-window-to-workspace = "browser";
      };
      "Super+Shift+2" = {
        move-window-to-workspace = "2";
      };
      "Super+Shift+3" = {
        move-window-to-workspace = "3";
      };
      "Super+Shift+4" = {
        move-window-to-workspace = "4";
      };
      "Super+Shift+5" = {
        move-window-to-workspace = "5";
      };
      "Super+Shift+6" = {
        move-window-to-workspace = "6";
      };
      "Super+Shift+7" = {
        move-window-to-workspace = "communication";
      };
      "Super+Shift+8" = {
        move-window-to-workspace = "gaming";
      };
      "Super+Shift+9" = {
        move-window-to-workspace = "x";
      };
      "Super+Shift+Ctrl+F1" = {
        set-window-height = "0%";
      };
      "Super+Shift+Ctrl+F10" = {
        set-window-height = "100%";
      };
      "Super+Shift+Ctrl+F2" = {
        set-window-height = "50%";
      };
      "Super+Shift+Ctrl+F3" = {
        set-window-height = "66%";
      };
      "Super+Shift+Ctrl+F4" = {
        set-window-height = "75%";
      };
      "Super+Shift+Ctrl+F5" = {
        set-window-height = "80%";
      };
      "Super+Shift+Ctrl+F6" = {
        set-window-height = "83.33%";
      };
      "Super+Shift+Ctrl+F7" = {
        set-window-height = "85.71%";
      };
      "Super+Shift+Ctrl+F8" = {
        set-window-height = "87.5%";
      };
      "Super+Shift+Ctrl+F9" = {
        set-window-height = "88.88%";
      };
      "Super+Shift+Down" = {
        move-window-down = { };
      };
      "Super+Shift+End" = {
        move-column-to-last = { };
      };
      "Super+Shift+F1" = {
        set-column-width = "0%";
      };
      "Super+Shift+F10" = {
        set-column-width = "100%";
      };
      "Super+Shift+F2" = {
        set-column-width = "50%";
      };
      "Super+Shift+F3" = {
        set-column-width = "66%";
      };
      "Super+Shift+F4" = {
        set-column-width = "75%";
      };
      "Super+Shift+F5" = {
        set-column-width = "80%";
      };
      "Super+Shift+F6" = {
        set-column-width = "83.33%";
      };
      "Super+Shift+F7" = {
        set-column-width = "85.71%";
      };
      "Super+Shift+F8" = {
        set-column-width = "87.5%";
      };
      "Super+Shift+F9" = {
        set-column-width = "88.88%";
      };
      "Super+Shift+Home" = {
        move-column-to-first = { };
      };
      "Super+Shift+Return" = {
        spawn = [
          "${wezterm}"
          "start"
          "--cwd"
          "/home/sidharta/lsbots/"
        ];
      };
      "Super+Shift+Up" = {
        move-window-up = { };
      };
      "Super+Shift+f" = {
        fullscreen-window = { };
      };
      "Super+Shift+i" = {
        move-window-to-workspace-up = { };
      };
      "Super+Shift+k" = {
        move-window-to-workspace-down = { };
      };
      "Super+Shift+q" = {
        spawn-sh = "${niri} msg --json focused-window | ${jq} --raw-output .pid | ${xargs} kill -9";
      };
      "Super+Shift+v" = {
        spawn = [ "${paste-qrcode}" ];
      };
      "Super+Shift+x" = {
        toggle-window-floating = { };
      };
      "Super+Up" = {
        focus-window-up = { };
      };
      "Super+b" = {
        set-dynamic-cast-window = { };
      };
      "Super+c" = {
        center-window = { };
      };
      "Super+ctrl+shift+Down" = {
        move-window-down = { };
      };
      "Super+ctrl+shift+Left" = {
        consume-or-expel-window-left = { };
      };
      "Super+ctrl+shift+Right" = {
        consume-or-expel-window-right = { };
      };
      "Super+ctrl+shift+Up" = {
        move-window-up = { };
      };
      "Super+equal" = {
        reset-window-height = { };
      };
      "Super+f" = {
        maximize-column = { };
      };
      "Super+i" = {
        focus-workspace-up = { };
      };
      "Super+j" = {
        focus-column-left = { };
      };
      "Super+k" = {
        focus-workspace-down = { };
      };
      "Super+l" = {
        focus-column-right = { };
      };
      "Super+q" = {
        close-window = { };
      };
      "Super+question" = {
        show-hotkey-overlay = { };
      };
      "Super+shift+Left" = {
        move-column-left = { };
      };
      "Super+shift+Right" = {
        move-column-right = { };
      };
      "Super+shift+j" = {
        move-column-left = { };
      };
      "Super+shift+l" = {
        move-column-right = { };
      };
      "Super+t" = {
        toggle-column-tabbed-display = { };
      };
      "Super+tab" = {
        toggle-overview = { };
      };
      "Super+x" = {
        switch-focus-between-floating-and-tiling = { };
      };
    };
}
