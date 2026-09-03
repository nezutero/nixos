{ ... }:
{
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
  # Point Jellyfin at a real media library once you have one, e.g.:
  # services.jellyfin.dataDir = "/mnt/data/jellyfin";
}
