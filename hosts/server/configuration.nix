{
  config,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../profiles/server.nix
  ];

  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";

      content = {
        type = "gpt";

        partitions = {
          boot = {
            size = "1M";
            type = "ef02";
          };

          root = {
            size = "100%";

            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "hetzner-server";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYZ+NmHXxKkupJwC2+8VnkwmyyeAGgiGza3Q8XeifS3 me@nezutero.dev"
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  environment.systemPackages = with pkgs; [
    neovim
    git
    wget
    tmux
  ];

  system.stateVersion = "26.05";
}
