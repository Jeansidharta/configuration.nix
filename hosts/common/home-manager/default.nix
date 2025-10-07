{
  config,
  pkgs,
  hostname,
  main-user,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./waypaper.nix
    ./hyprlock.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];
  home = {
    # pointerCursor = {
    #   name = "Bibata Translucent";
    #   package = pkgs.bibata-cursors-translucent;
    #   size = 48;
    #   gtk.enable = true;
    # };

    packages = with pkgs; [
      # === Regular Desktop ===

      btop # Process manager
      wl-clipboard # Clipboard software
      bat # Replacement for the gnu `cat` command
      sxiv # Simple image viewer
      lmms # Music production
      eza # Replacement for the gnu `ls` command
      splatmoji # Emoji / Emoticon selector
      inkscape # Vector image editor
      htmlq # CLI tool for filtering HTML pages
      jq # CLI tool for filtering Json data
      pavucontrol # GUI for changing audio stuff
      libnotify # Send d-bus notification through the terminal
      yt-dlp # Download youtube videos
      unzip # Unzip tool
      hyprpicker # Cool color picker
      wpaperd
      imhex # A very nice hex editor
      libreoffice # Office suite

      helvum # Manipulate Pipewire connections
      qpwgraph # Manipulate Pipewire connections
      usbutils # Tool for manipulating USB
      tmsu # File tagging tool
      obsidian # Note taking app
      moreutils # A collection of tools to improve bash scripting

      xh # A CURL replacement
      du-dust # A more modern du
      fselect # A file finder with SQL syntax
      mpc # cli to controll the mpd daemon
      dust # A modern replacement for the du command
      nh # A nix helper
      nix-output-monitor # Show nix dependencies
      nix-tree
      nix-du
      lazygit
      nftables # firewall frontend
      quickshell

      socat # Tool for connecting/debugging read/write interfaces
      tcpdump # Dump tcp connections
      nmap # map network
      calc # gnu calc

      (plover.with-plugins (ps: [
        ps.plover-lapwing-aio
        (ps.plover-uinput.overrideAttrs (old: {
          propagatedBuildInputs = [
            # pkgs.python311Packages.evdev
            pkgs.xkbcommon-0-10-0
          ];
        }))
      ]))

      kitty # Backup terminal in case ghostty dies

      mypkgs.neovim
      mypkgs.sqlite-diagram

      # === Non free ===
      discord
      telegram-desktop

      # === Fonts ===
      jetbrains-mono
    ];

    shellAliases =
      let
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
        "ses" = "systemctl --user";
        "vim" = "nvim";
        "vi" = "nvim";
        "ls" = "eza";

        "cdtmp" = "cd $(mktemp --dir)";

        "nvim-test" = "nix run /home/sidharta/projects/neovim-flake --no-net --offline -- ";
        "replace" = "${replace}";

        "nix-print-roots" = "nix-store --gc --print-roots | less";

        "minicom" = "minicom -w -t xterm -l -R UTF-8";
        "du" = "${pkgs.dust}/bin/dust";
      };

    stateVersion = "24.05";
  };

  programs.satty = {
    enable = true;
    config = {
      general = {
        initial-tool = "brush";
        output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
        save-after-copy = true;
      };
    };
  };

  programs.ewwCustom = {
    enable = true;
    systemdService = true;
    systemdTarget = "graphical-session.target";
    startingOpenWindow = "top_bar";
  };

  programs.firefox = {
    enable = true;
    profiles.default = {
      isDefault = true;
      name = "default";
      id = 0;
      settings = {
      };
    };
  };
  programs.mpv = {
    enable = true;
    config = {
      ytdl-raw-options = "extractor-args=\"youtube:player-client=default,-tv_simply\"";
    };
  };
  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland-unwrapped;
  };
  programs.fd.enable = true;
  programs.ripgrep.enable = true;

  programs.zk = {
    enable = true;
    settings = {
      notebook = {
        dir = "~/notes";
      };
    };
  };

  services.flameshot.enable = true;
  services.dunst.enable = true;
  services.udiskie.enable = true;
  systemd.user.startServices = true;

  services.cliphist = {
    enable = true;
    systemdTargets = [ "graphical-session.target" ];
  };

  services.swww.enable = true;

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = builtins.readFile ./wezterm.lua;
  };

  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      show_startup_tips = false;
      copy_command = "wl-copy";
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    clock24 = true;
    baseIndex = 1;
    shortcut = "Space";
    extraConfig = ''
      set -g display-time 0
      set -g renumber-windows on
      set -g set-titles on
      set -sa terminal-overrides ",xterm*:Tc"

      setw -g window-status-current-format ' #I #W #F '
      set -g status-right '%m-%d %H:%M '
      set -g status-right-length 50

      bind y attach-session -c "#{pane_current_path}"

      bind -N "Restart Configuration" C-r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."

      bind -nN "Select Left Pane"  C-Left  select-pane -L
      bind -nN "Select Right Pane" C-Right select-pane -R
      bind -nN "Select Up Pane"    C-Up    select-pane -U
      bind -nN "Select Down Pane"  C-Down  select-pane -D

      bind -nN "Resize Left Pane"  S-Left  resize-pane -L
      bind -nN "Resize Right Pane" S-Right resize-pane -R
      bind -nN "Resize Up Pane"    S-Up    resize-pane -U
      bind -nN "Resize Down Pane"  S-Down  resize-pane -D

      bind -nN "Next Window" C-S-Right select-window -n
      bind -nN "Prev Window" C-S-Left  select-window -p

      bind -N "Split vertical"   v split-window -v -c "#{pane_current_path}"
      bind -N "Split horizontal" h split-window -h -c "#{pane_current_path}"
      bind -N "Split vertical"   - split-window -v -c "#{pane_current_path}"
      bind -N "Split horizontal" | split-window -h -c "#{pane_current_path}"
    '';
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/home/sidharta/music";
    extraConfig = ''
      audio_output {
        type            "pipewire"
        name            "PipeWire Sound Server"
      }
    '';
  };
  programs.ncmpcpp.enable = true;
}
