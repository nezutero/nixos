{
  config,
  pkgs,
  lib,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in
{
  home.username = "nezutero";
  home.homeDirectory = "/home/nezutero";
  home.stateVersion = "26.05";

  home.activation.bootstrap = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # ── SSH key ──────────────────────────────────────────────────
    if [ ! -f "${config.home.homeDirectory}/.ssh/id_ed25519" ]; then
        mkdir -p "${config.home.homeDirectory}/.ssh"
            chmod 700 "${config.home.homeDirectory}/.ssh"

            ${pkgs.openssh}/bin/ssh-keygen \
            -t ed25519 \
            -C "me@nezutero.dev" \
            -f "${config.home.homeDirectory}/.ssh/id_ed25519" \
            -N ""

            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  SSH key generated — add to GitHub:"
            echo "  https://github.com/settings/ssh/new"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            cat "${config.home.homeDirectory}/.ssh/id_ed25519.pub"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            fi

            # ── Repos (HTTPS, no auth needed for public repos) ───────────
            if [ ! -d "${config.home.homeDirectory}/dotfiles" ]; then
                ${pkgs.git}/bin/git clone \
                    https://github.com/nezutero/dotfiles.git \
                    "${config.home.homeDirectory}/dotfiles"
            fi
  '';

  home.activation.zenBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_PROFILE=$(find "$HOME/.config/zen" -maxdepth 1 -type d -name "*.Default Profile" | head -n1)

    if [ -n "$ZEN_PROFILE" ]; then
        mkdir -p "$ZEN_PROFILE/chrome"
        ln -sf "$HOME/dotfiles/other/zen/user.js" "$ZEN_PROFILE/user.js"
        ln -sf "$HOME/dotfiles/other/zen/chrome/userChrome.css" "$ZEN_PROFILE/chrome/userChrome.css"
    fi
  '';

  home.sessionPath = [
    "${config.home.homeDirectory}/dotfiles/scripts"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "foot";
    BROWSER = "zen-beta";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "z"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      q = "exit";
      v = "nvim";
      vi = "nvim";
      vim = "nvim";
      c = "clear";
      gtp = "cd $HOME/projs && clear && ls -a";
      gtd = "cd $HOME/dotfiles";
      gtc = "cd $HOME/nixos";
      gtn = "cd $HOME/notes";
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gcm = "git commit -m";
      gcb = "git checkout -b";
      gco = "git checkout";
      gpl = "git pull";
      gps = "git push";
      gcl = "git clone";
      gbd = "git branch -D";
      gbs = "git switch";
      f = "$HOME/dotfiles/scripts/fzfman.sh";
      ls = "eza";
      cat = "bat";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nezutero";
        email = "me@nezutero.dev";
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
      };
      "codeberg.org" = {
        HostName = "codeberg.org";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  # points symlinks -> ~/dotfiles
  xdg.configFile = {
    "nvim".source = link "nvim";
    "hypr".source = link "hypr";
    "waybar".source = link "waybar";
    "alacritty".source = link "alacritty";
    "dunst".source = link "dunst";
    "rofi".source = link "rofi";
    #"swaylock".source = link "swaylock";
    #"sway".source = link "sway";
    "foot".source = link "foot";
    "tmux".source = link "tmux";
    "yazi".source = link "yazi";
    "fastfetch".source = link "fastfetch";
    "rmpc".source = link "rmpc";
    "zathura".source = link "zathura";
  };

  services.mpd = {
    enable = true;

    musicDirectory = "/home/nezutero/music";

    extraConfig = ''
      restore_paused "no"

      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';

    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
  };

  # services.swayidle = {
  #   enable = true;

  #   events = [
  #     {
  #       event = "before-sleep";
  #       command = "${pkgs.swaylock}/bin/swaylock";
  #     }
  #   ];

  #   timeouts = [
  #     {
  #       timeout = 600;
  #       command = "${pkgs.brightnessctl}/bin/brightnessctl -e4 -s set 25%";
  #       resumeCommand = "${pkgs.brightnessctl}/bin/brightnessctl -r";
  #     }

  #     {
  #       timeout = 1200;
  #       command = "${pkgs.swaylock}/bin/swaylock";
  #     }

  #     {
  #       timeout = 2400;
  #       command = "${pkgs.systemd}/bin/systemctl suspend";
  #     }
  #   ];
  # };

  gtk = {
    enable = true;

    font = {
      name = "Inter";
      size = 12;
    };

    theme = {
      name = "Kanagawa-BL";
      package = pkgs.kanagawa-gtk-theme;
    };

    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    exec = "nvim %F";
    terminal = true;
    type = "Application";
    mimeType = [
      "text/plain"
      "text/markdown"
      "application/json"
    ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "zen-beta.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "audio/mpeg" = "rmpc.desktop";
      "audio/flac" = "rmpc.desktop";
      "audio/ogg" = "rmpc.desktop";
      "audio/wav" = "rmpc.desktop";
      "text/plain" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        "onlyoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
        "onlyoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-calc.desktop";
      "application/vnd.ms-word.document.macroEnabled.12" = "onlyoffice-impress.desktop";
      "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = "onlyoffice-impress.desktop";
      "application/msword" = "onlyoffice-impress.desktop";
      "application/vnd.ms-powerpoint" = "onlyoffice-impress.desktop";
      "application/vnd.ms-excel" = "onlyoffice-calc.desktop";
    };
  };

  systemd.user.services.protonmail-bridge = {
    Unit.Description = "Proton Mail Bridge";
    Service = {
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
