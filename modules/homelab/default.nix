{ ... }:
{
  imports = [
    ./secrets.nix
    ./caddy.nix
    ./immich.nix
    ./vaultwarden.nix
    ./uptime-kuma.nix
    ./miniflux.nix
    ./jellyfin.nix
    ./ntfy.nix
    ./backups.nix
  ];
}
