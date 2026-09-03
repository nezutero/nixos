{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "photos.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.immich.port}
      '';
      "vault.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}
      '';
      "status.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:3001
      '';
      "feeds.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
      "watch.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';
      "ntfy.nezutero.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:2586
      '';
    };
  };
}
