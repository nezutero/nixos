{ ... }:
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.nezutero.dev";
      listen-http = "127.0.0.1:2586";
      behind-proxy = true;
      auth-file = "/var/lib/ntfy-sh/user.db";
      auth-default-access = "deny-all"; # nobody reads/writes without logging in
      enable-login = true;
      enable-signup = false;
    };
  };
}
