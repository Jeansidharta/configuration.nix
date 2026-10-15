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
      ghostty = lib.getExe pkgs.ghostty;
      drawy = lib.getExe pkgs.drawy;
      satty = lib.getExe pkgs.satty;
      wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
      mpc = lib.getExe pkgs.mpc;

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
      act = action: { ${action} = { }; };
      bkv = action: v: { ${action} = v; };
      spawn = prog: args: { spawn = [ prog ] ++ args; };
      spawn-sh = cmd: { spawn-sh = cmd; };
    in
    {
      #######################################
      ########### Window movement ###########
      #######################################

      # Focus windows
      "Super+h" = act "focus-column-left";
      "Super+j" = act "focus-window-or-workspace-down";
      "Super+k" = act "focus-window-or-workspace-up";
      "Super+l" = act "focus-column-right";
      # Move Windows
      "Super+Shift+h" = act "move-column-left";
      "Super+Shift+j" = act "move-column-to-workspace-down";
      "Super+Shift+k" = act "move-column-to-workspace-up";
      "Super+Shift+l" = act "move-column-right";
      # Swap columns
      "Super+Ctrl+Shift+h" = act "consume-or-expel-window-left";
      "Super+Ctrl+Shift+j" = act "move-window-down";
      "Super+Ctrl+Shift+k" = act "move-window-up";
      "Super+Ctrl+Shift+l" = act "consume-or-expel-window-right";

      #######################################
      ########## Window Sizing ##############
      #######################################

      # Horizontal
      "Super+F1" = act "maximize-column";
      "Super+F2" = bkv "set-column-width" "50%";
      "Super+F3" = bkv "set-column-width" "33%";
      "Super+F4" = bkv "set-column-width" "25%";
      "Super+F5" = bkv "set-column-width" "20%";
      "Super+F6" = bkv "set-column-width" "16.66%";
      "Super+F7" = bkv "set-column-width" "14.28%";
      "Super+F8" = bkv "set-column-width" "12.5%";
      "Super+F9" = bkv "set-column-width" "11.11%";
      "Super+F10" = bkv "set-column-width" "0%";

      # Vertical
      "Super+Ctrl+F1" = bkv "set-window-height" "100%";
      "Super+Ctrl+F2" = bkv "set-window-height" "50%";
      "Super+Ctrl+F3" = bkv "set-window-height" "33%";
      "Super+Ctrl+F4" = bkv "set-window-height" "25%";
      "Super+Ctrl+F5" = bkv "set-window-height" "20%";
      "Super+Ctrl+F6" = bkv "set-window-height" "16.66%";
      "Super+Ctrl+F7" = bkv "set-window-height" "14.28%";
      "Super+Ctrl+F8" = bkv "set-window-height" "12.5%";
      "Super+Ctrl+F9" = bkv "set-window-height" "11.11%";
      "Super+Ctrl+F10" = bkv "set-window-height" "0%";

      # Horizontal Inverted
      "Super+Shift+F1" = act "expand-column-to-available-width";
      "Super+Shift+F2" = bkv "set-column-width" "50%";
      "Super+Shift+F3" = bkv "set-column-width" "66%";
      "Super+Shift+F4" = bkv "set-column-width" "75%";
      "Super+Shift+F5" = bkv "set-column-width" "80%";
      "Super+Shift+F6" = bkv "set-column-width" "83.33%";
      "Super+Shift+F7" = bkv "set-column-width" "85.71%";
      "Super+Shift+F8" = bkv "set-column-width" "87.5%";
      "Super+Shift+F9" = bkv "set-column-width" "88.88%";
      "Super+Shift+F10" = bkv "set-column-width" "100%";

      # Vertical Inverted
      "Super+Shift+Ctrl+F1" = act "reset-window-height";
      "Super+Shift+Ctrl+F2" = bkv "set-window-height" "50%";
      "Super+Shift+Ctrl+F3" = bkv "set-window-height" "66%";
      "Super+Shift+Ctrl+F4" = bkv "set-window-height" "75%";
      "Super+Shift+Ctrl+F5" = bkv "set-window-height" "80%";
      "Super+Shift+Ctrl+F6" = bkv "set-window-height" "83.33%";
      "Super+Shift+Ctrl+F7" = bkv "set-window-height" "85.71%";
      "Super+Shift+Ctrl+F8" = bkv "set-window-height" "87.5%";
      "Super+Shift+Ctrl+F9" = bkv "set-window-height" "88.88%";
      "Super+Shift+Ctrl+F10" = bkv "set-window-height" "100%";

      #######################################
      ############ Workspaces ###############
      #######################################

      # Focus
      "Super+1" = bkv "focus-workspace" "browser";
      "Super+2" = bkv "focus-workspace" "2";
      "Super+3" = bkv "focus-workspace" "3";
      "Super+4" = bkv "focus-workspace" "4";
      "Super+5" = bkv "focus-workspace" "5";
      "Super+6" = bkv "focus-workspace" "6";
      "Super+7" = bkv "focus-workspace" "communication";
      "Super+8" = bkv "focus-workspace" "gaming";
      "Super+9" = bkv "focus-workspace" "x";
      # Move
      "Super+Shift+1" = bkv "move-window-to-workspace" "browser";
      "Super+Shift+2" = bkv "move-window-to-workspace" "2";
      "Super+Shift+3" = bkv "move-window-to-workspace" "3";
      "Super+Shift+4" = bkv "move-window-to-workspace" "4";
      "Super+Shift+5" = bkv "move-window-to-workspace" "5";
      "Super+Shift+6" = bkv "move-window-to-workspace" "6";
      "Super+Shift+7" = bkv "move-window-to-workspace" "communication";
      "Super+Shift+8" = bkv "move-window-to-workspace" "gaming";
      "Super+Shift+9" = bkv "move-window-to-workspace" "x";

      #######################################
      ######### Misc/Applications ###########
      #######################################
      # Applications
      "Super+Return" = spawn ghostty [ ];
      "Super+Shift+Return" = spawn ghostty [ "--working-directory=/home/sidharta/lsbots/" ];
      "Super+d" = spawn drawy [ "default-board" ];

      # Screen Sharing
      "Super+Alt+b" = act "set-dynamic-cast-monitor";
      "Super+b" = act "set-dynamic-cast-window";

      # Print Screen
      "Print" = act "screenshot-screen";
      "Shift+Print" = act "screenshot-window";
      "Super+e" =
        spawn-sh "${wl-paste} | ${satty} --filename - --initial-tool crop --output-filename \"/home/sidharta/screenshots-niri/%Y-%m-%d_%H:%M:%S.png\" --save-after-copy";

      # Volume/Music
      "Shift+XF86AudioLowerVolume" = spawn mpc [ "volume -10" ];
      "Shift+XF86AudioRaiseVolume" = spawn mpc [ "volume +10" ];
      "Shift+XF86AudioNext" = spawn mpc [ "next" ];
      "Shift+XF86AudioPlay" = spawn mpc [ "toggle" ];
      "Shift+XF86AudioPrev" = spawn mpc [ "prev" ];

      # Window State
      "Super+f" = act "fullscreen-window";
      "Super+Shift+f" = act " toggle-windowed-fullscreen";
      "Super+x" = act "switch-focus-between-floating-and-tiling";
      "Super+Shift+x" = act "toggle-window-floating";
      "Super+tab" = act "toggle-overview";
      "Super+t" = act "toggle-column-tabbed-display";
      "Super+c" = act "center-window";

      # Close windows
      "Super+q" = act "close-window";
      "Super+Shift+q" =
        bkv "spawn-sh" "${niri} msg --json focused-window | ${jq} --raw-output .pid | ${xargs} kill -9";

      "Super+Shift+v" = bkv "spawn" [ "${paste-qrcode}" ];
    };
}
