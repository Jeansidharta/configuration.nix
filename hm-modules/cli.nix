{ pkgs, lib, ... }:
{

  programs.btop.enable = true;
  programs.direnv.enable = true;
  programs.fd.enable = true;
  programs.ripgrep.enable = true;

  home.packages = with pkgs; [
    btop # Process manager
    bat # Replacement for the gnu `cat` command
    eza # Replacement for the gnu `ls` command
    htmlq # CLI tool for filtering HTML pages
    jq # CLI tool for filtering Json data
    moreutils # A collection of tools to improve bash scripting
    tmsu # File tagging tool
    dust # A more modern du
    fselect # A file finder with SQL syntax
    nftables # firewall frontend
    socat # Tool for connecting/debugging read/write interfaces
    unar # Unzip tool
    yt-dlp # Download youtube videos
    tcpdump # Dump tcp connections
    darkhttpd # Very simple http server
    nmap # map network
    calc # gnu calc
    conntrack-tools # Show connections tracked by the kernel
    dig.dnsutils # DNS testing tool
    pciutils # lspci command to show current pci devices
    powertop # Show power usage
    strace # Show all syscalls made by application
    traceroute # Shows the route to a destination on the internet
    neovim

    (pkgs.writeScriptBin "root-derivation" ''
      #!/usr/bin/env bash

      path="$(which "$1")"
      path="$(readlink -f "$path")"
      path="$(dirname "$path")"

      echo "$path"
    '')
  ];

  systemd.user.startServices = true;

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

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "sidharta";
        email = "jeansidharta@gmail.com";
      };
      aliases = {
        lg = "log --graph --format=\"format:%C(auto)%h%C(reset) %C(white)-%C(reset) %C(italic blue)%ad%C(reset) %C(italic cyan)(%ar)%C(reset)%C(auto)%d%C(reset)%n %C(white)⤷%C(reset) %s %C(241)- %aN <%aE>%C(reset)%n%w(0,7,7)%+(trailers:only,unfold)\"";
        s = "status --short";
        a = "add .";
        c = "commit";
        ac = "!sh 'git add . && git commit'";
        ca = "commit --amend";
      };
      init.defaultBranch = "main";
      core = {
        autocrlf = "input";
        editor = "vim";
      };
      fetch.prune = true;
      push.autoSetupRemote = true;
      safe.directory = "/etc/nixos";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[\\[❯\\]](bold green)";
        error_symbol = "[\\[✖\\]](bold red)";
        vimcmd_symbol = "[\\[N\\]](bold purple)";
      };
      memory_usage = {
        disabled = false;
        threshold = 76;
      };
      status.disabled = false;
      sudo.disabled = false;
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    # initExtra = ''
    # export NIX_BUILD_SHELL=${nix-zshell}
    # '';
  };

  home.shellAliases =
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
      "jes" = "journalctl --user";
      "vim" = "nvim";
      "vi" = "nvim";
      "ls" = "eza";

      "cdtmp" = "cd $(mktemp --dir)";

      "nvim-test" = "nix run /home/sidharta/projects/neovim-flake --no-net --offline -- ";
      "replace" = "${replace}";

      "nix-print-roots" = "nix-store --gc --print-roots | less";

      "minicom" = "minicom -w -t xterm -l -R UTF-8";
      "du" = "${pkgs.dust}/bin/dust";

      "rsync" =
        "${pkgs.rsync}/bin/rsync -avzh --append-verify --inplace --checksum --info=progress1,stats3";

      "dbl" = "${lib.getExe pkgs.wezterm} start --cwd .";
    };

  home.stateVersion = "24.05";
}
