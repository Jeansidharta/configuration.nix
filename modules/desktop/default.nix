{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (config.lib.overlay-helpers) mkUnstable overlay-flake;

  hm-module =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      home.packages = with pkgs; [
        wl-clipboard # Clipboard software
        libnotify # Send d-bus notification through the terminal
        crosspipe # Manipulate Pipewire connections
        qpwgraph # Manipulate Pipewire connections
        wiremix # TUI for configuring pipewire audio

        htmlq # CLI tool for filtering HTML pages
        dive # See container image layers
        lazygit # git tui
        fzf

        drawy # Infinite canvas
        kubernetes

        wireshark
        yazi # File picker

        # === Fonts ===
        jetbrains-mono

        candy-icons
        kdePackages.breeze-icons
        adwaita-icon-theme
      ];

      programs.zsh.initContent = ''
        if [[ $TERM != "dumb" ]]; then
           source ${
             pkgs.runCommand "kubectl-completions-zsh" { } "${pkgs.kubernetes}/bin/kubectl completion zsh > $out"
           }
         fi
      '';

      imports = [ ./firefox.nix ];

      home.shellAliases = {
        "dbl" = "${lib.getExe pkgs.wezterm} start --cwd .";
      };

      programs.nchat = {
        enable = true;
        settings-color = "ayu-dark";
        settings-ui = {
          desktop_notify_enabled = 1;
          desktop_notify_active_noncurrent = 1;
          desktop_notify_inactive = 1;
          desktop_notify_connectivity = 1;
          message_open_command = "${lib.getExe pkgs.neovim} -";
          file_picker_command = "${lib.getExe pkgs.yazi} --chooser-file \"%1\"";
          home_fetch_all = 1;
        };
        settings-key = {
          backward_kill_word = "KEY_CTRLW";
          backward_word = "\\4001052"; # CTRL LEFT
          forward_word = "\\4001071"; # CTRL RIGHT
          begin_line = "KEY_HOME";
          end_line = "KEY_END";
          home = "\\33\\146"; # ALT + F
          end = "\\33\\147"; # ALT + G

          open_link = "KEY_NONE";
        };
      };

      programs.yt-dlp = {
        enable = true;
        settings = {
          sponsorblock-mark = "all";
        };
      };

      programs.satty = {
        enable = true;
        settings = {
          general = {
            initial-tool = "brush";
            output-filename = "/tmp/screenshot-%Y-%m-%d_%H:%M:%S.png";
            save-after-copy = true;
            copy-command = "wl-copy -t image/png";
            # disable-notifications = true;
            actions-on-right-click = [ "save-to-clipboard" ];
            actions-on-enter = [ "save-to-clipboard" ];
          };
          color-palette = {
            palette = [
              "#ff0000"
              "#00ff00"
              "#0000ff"
              "#ff66cc"
              "#00ffd5"
              "#000000"
              "#ffffff"
            ];
          };
        };
      };

      programs.mpv = {
        enable = true;
        config = {
          ytdl-raw-options = "extractor-args=\"youtube:player-client=default,-tv_simply\"";
        };
      };

      programs.zk = {
        enable = true;
        settings = {
          notebook = {
            dir = "~/notes";
          };
        };
      };

      services.dunst.enable = true;
      services.udiskie.enable = true;

      services.cliphist = {
        enable = true;
        systemdTargets = [ "graphical-session.target" ];
      };

      programs.wezterm = {
        enable = true;
        enableZshIntegration = true;
        extraConfig = builtins.readFile ./wezterm.lua;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          format = lib.join "" [
            "$username"
            "$hostname"
            "$localip"
            "$shlvl"
            "$singularity"
            "$kubernetes"
            "$nats"
            "$directory"
            "$vcsh"
            "$fossil_branch"
            "$fossil_metrics"
            "$git_branch"
            "$git_commit"
            "$git_state"
            "$git_metrics"
            "$git_status"
            "$hg_branch"
            "$hg_state"
            "$pijul_channel"
            "$docker_context"
            "$package"
            "$bun"
            "$c"
            "$cmake"
            "$cobol"
            "$cpp"
            "$daml"
            "$dart"
            "$deno"
            "$dotnet"
            "$elixir"
            "$elm"
            "$erlang"
            "$fennel"
            "$fortran"
            "$gleam"
            "$golang"
            "$gradle"
            "$haskell"
            "$haxe"
            "$helm"
            "$java"
            "$julia"
            "$kotlin"
            "$lua"
            "$maven"
            "$mojo"
            "$nim"
            "$nodejs"
            "$ocaml"
            "$odin"
            "$opa"
            "$perl"
            "$php"
            "$pulumi"
            "$purescript"
            "$python"
            "$quarto"
            "$raku"
            "$rlang"
            "$red"
            "$ruby"
            "$rust"
            "$scala"
            "$solidity"
            "$swift"
            "$terraform"
            "$typst"
            "$vlang"
            "$vagrant"
            "$xmake"
            "$zig"
            "$buf"
            "$guix_shell"
            "$nix_shell"
            "$conda"
            "$pixi"
            "$meson"
            "$spack"
            "$memory_usage"
            "$aws"
            "$gcloud"
            "$openstack"
            "$azure"
            "$direnv"
            "$env_var"
            "$mise"
            "$crystal"
            "$custom"
            "$sudo"
            "\${custom.jj}"
            "\${custom.git_status}"
            "\${custom.git_commit}"
            "\${custom.git_metrics}"
            "\${custom.git_branch}"
            "$cmd_duration"
            "$line_break"
            "$jobs"
            "$battery"
            "$time"
            "$status"
            "$container"
            "$netns"
            "$os"
            "$shell"
            "$character"
          ];
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
          # custom module for jj status
          git_status.disabled = true;
          git_commit.disabled = true;
          git_metrics.disabled = true;
          git_branch.disabled = true;
          custom = {
            # copied from https://github.com/jj-vcs/jj/wiki/Starship#alternative-prompt
            jj = {
              description = "The current jj status";
              when = "jj --ignore-working-copy root";
              symbol = "🥋 ";
              command = ''
                jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
                  separate(" ",
                    change_id.shortest(4),
                    bookmarks,
                    "|",
                    concat(
                      if(conflict, "💥"),
                      if(divergent, "🚧"),
                      if(hidden, "👻"),
                      if(immutable, "🔒"),
                    ),
                    raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
                    raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                      truncate_end(29, description.first_line(), "…"),
                      "(no description set)",
                    ) ++ raw_escape_sequence("\x1b[0m"),
                  )
                '
              '';
            };
            git_status = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_status";
              style = ""; # This disables the default "(bold green)" style
              description = "Only show git_status if we're not in a jj repo";
            };
            git_commit = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_commit";
              style = "";
              description = "Only show git_commit if we're not in a jj repo";
            };
            git_metrics = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_metrics";
              description = "Only show git_metrics if we're not in a jj repo";
              style = "";
            };
            git_branch = {
              when = "! jj --ignore-working-copy root";
              command = "starship module git_branch";
              description = "Only show git_branch if we're not in a jj repo";
              style = "";
            };
          };
        };
      };

      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            email = "jeansidharta@gmail.com";
            name = "j_sidharta";
          };
          ui.default-command = "log";
        };
      };

      # Jujutsu TUI
      programs.jjui = {
        enable = true;
      };

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
in
{
  imports = [
  ];

  home-manager.users.sidharta.imports = [
    hm-module
    ../../options/niri.nix
  ];

  nixpkgs.overlays = [
    (mkUnstable "wezterm")
    (overlay-flake "wiremix")
  ];
  hardware.graphics.enable = true;
  services.udisks2.enable = true;

  # hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  users.users.sidharta = {
    extraGroups = [
      "dialout"
      "pipewire"
    ];
    packages = [ pkgs.home-manager ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
  };

  services.udev.extraRules = ''
    # For developing with a Raspberry PI
    ATTRS{vendor}=="RPI", ATTRS{model}=="RP2", MODE="0666"

    # Serial port of my keyboard for Stenography
    ATTRS{product}=="stenidol", SYMLINK+="stenidol", OWNER="sidharta"

    ATTRS{serial}=="BZEEk13AL19", MODE="0666"
    ATTR{manufacturer}=="Stenograph", MODE="0666"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  security.rtkit.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [
    pkgs.dbus.lib
    pkgs.libGL
    pkgs.libx11
    pkgs.libxext
    pkgs.libxcursor
    pkgs.libxinerama
    pkgs.libxi
    pkgs.libxfixes
    pkgs.libxrandr
    pkgs.libxscrnsaver
    pkgs.libxxf86vm
    pkgs.libxkbcommon
    pkgs.kdePackages.wayland
    pkgs.libpulseaudio
    pkgs.alsa-lib
    pkgs.sndio
    pkgs.nas
  ];
}
