{ ... }:
{
  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/mnt/data/immich";
    openFirewall = false; # only reachable through Caddy
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-id/scsi-0HC_Volume_XXXXXXXX";
    fsType = "ext4";
  };
}
