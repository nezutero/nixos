{
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;
  virtualisation.podman.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
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
}
