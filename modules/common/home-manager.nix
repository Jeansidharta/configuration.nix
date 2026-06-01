{
  pkgs,
  lib,
  inputs,
  ...
}:
{

  imports = [
    inputs.theme.outputs.home-manager-module
    ../../options/home-manager/nchat.nix
  ];

  xdg = {
    enable = true;
    systemDirs.data = [ "/etc/profiles/per-user/sidharta/share" ];
    cacheHome = "/home/sidharta/.local/cache";
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
    QS_ICON_THEME = "candy-icons";
  };

  systemd.user.startServices = true;

  # programs.zellij = {
  #   enable = true;
  #   extraConfig = builtins.readFile ./zellij.kdl;
  # };

  # programs.tmux = {
  #   enable = true;
  #   keyMode = "vi";
  #   mouse = true;
  #   escapeTime = 0;
  #   clock24 = true;
  #   baseIndex = 1;
  #   shortcut = "Space";
  #   extraConfig = ''
  #     set -g display-time 0
  #     set -g renumber-windows on
  #     set -g set-titles on
  #     set -sa terminal-overrides ",xterm*:Tc"
  #
  #     setw -g window-status-current-format ' #I #W #F '
  #     set -g status-right '%m-%d %H:%M '
  #     set -g status-right-length 50
  #
  #     bind y attach-session -c "#{pane_current_path}"
  #
  #     bind -N "Restart Configuration" C-r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
  #
  #     bind -nN "Select Left Pane"  C-Left  select-pane -L
  #     bind -nN "Select Right Pane" C-Right select-pane -R
  #     bind -nN "Select Up Pane"    C-Up    select-pane -U
  #     bind -nN "Select Down Pane"  C-Down  select-pane -D
  #
  #     bind -nN "Resize Left Pane"  S-Left  resize-pane -L
  #     bind -nN "Resize Right Pane" S-Right resize-pane -R
  #     bind -nN "Resize Up Pane"    S-Up    resize-pane -U
  #     bind -nN "Resize Down Pane"  S-Down  resize-pane -D
  #
  #     bind -nN "Next Window" C-S-Right select-window -n
  #     bind -nN "Prev Window" C-S-Left  select-window -p
  #
  #     bind -N "Split vertical"   v split-window -v -c "#{pane_current_path}"
  #     bind -N "Split horizontal" h split-window -h -c "#{pane_current_path}"
  #     bind -N "Split vertical"   - split-window -v -c "#{pane_current_path}"
  #     bind -N "Split horizontal" | split-window -h -c "#{pane_current_path}"
  #   '';
  # };

  home.file.".gdbinit".text = ''
    set print pretty on
    set print symbol-filename on
    set print array on
    set disassembly-flavor intel
  '';

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

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    # initExtra = ''
    # export NIX_BUILD_SHELL=${nix-zshell}
    # '';
  };

  home.shellAliases = {
    "ses" = "systemctl --user";
    "jes" = "journalctl --user";
    "vim" = "nvim";
    "vi" = "nvim";

    "cdf" = "cd $(fzf | basename)";
    "cdtmp" = "cd $(mktemp --dir)";

    "nvim-test" = "nix run /home/sidharta/projects/neovim-flake --no-net --offline -- ";

    "nix-print-roots" = "nix-store --gc --print-roots | less";

    "minicom" = "minicom -w -t xterm -l -R UTF-8";
    "du" = "${pkgs.dust}/bin/dust";

    "rsync" =
      "${pkgs.rsync}/bin/rsync -avzh --append-verify --inplace --checksum --info=progress1,stats3";
  };

  home.stateVersion = "24.05";
}
