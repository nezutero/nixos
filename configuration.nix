# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.resolved.enable = false;
  # networking.nameservers = [
  #  "extended.dns.mullvad.net"
  #  "194.242.2.6"
  # ];

  # Time zone
  time.timeZone = "Europe/Paris";

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "fr_FR.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."nezutero" = {
    isNormalUser = true;
    description = "nezutero";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # IF SWAY: swayfx wlsunset swayidle swaybg swaylock
  environment.systemPackages = with pkgs; [
    neovim
    clang
    clang-tools
    glibc
    lua-language-server
    nil
    wget
    waybar
    rofi
    zbar
    libnotify
    wtype
    hyprlock
    hyprpaper
    foot
    neomutt
    protonmail-bridge
    (pass.withExtensions (exts: with exts; [ pass-otp ]))
    jq
    dunst
    btop
    hyprsunset
    wl-clipboard
    grim
    slurp
    gimp
    wev
    tmux
    brightnessctl
    cliphist
    yazi
    ncdu
    podman
    pavucontrol
    fastfetch
    imagemagick
    fzf
    eza
    bat
    rofi-bluetooth
    jetbrains-mono
    gruvbox-material-gtk-theme
    gruvbox-plus-icons
    zsh
    fd
    adwaita-icon-theme
    ripgrep
    imv
    mpv
    git
    dig
    android-tools
    hakuneko
    kcc
    gdb
    calibre
    zathura
    obs-studio
    onlyoffice-desktopeditors
    tree
    docker
    distrobox
    tuigreet
    gcc
    rustc
    python3
    cargo
    gnupg
    pinentry-curses
    telegram-desktop
    signal-desktop
    nodejs
    go
    unzip
    rmpc
    thunderbird
    protonmail-bridge
    killall
    kanagawa-gtk-theme
    tor-browser
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    PASSWORD_STORE_EXTENSIONS_DIR = "/run/current-system/sw/lib/password-store/extensions/";
  };

  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono
      jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Inter" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.hyprland.enable = true;

  programs.zsh.enable = true;

  # ── Automated maintenance ────────────────────
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "weekly" ];

  # ── Background services ──────────────────────
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;
  virtualisation.podman.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    icu
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true; # helps GTK apps / file managers see removable media

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05";
}
