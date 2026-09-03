{ config, ... }:
{
  sops.secrets."miniflux_admin_credentials" = { };

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = config.sops.secrets."miniflux_admin_credentials".path;
    config = {
      LISTEN_ADDR = "127.0.0.1:8080";
      BASE_URL = "https://feeds.nezutero.dev/";
    };
  };
}
