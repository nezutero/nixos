{ ... }:

{
  networking.networkmanager.enable = true;

  services.resolved = {
    enable = true;

    settings.Resolve = {
      DNS = [
        "194.242.2.5#extended.dns.mullvad.net"
      ];

      DNSOverTLS = "yes";
      DNSSEC = "allow-downgrade";

      # send all dns queries through this resolver
      Domains = [ "~." ];
    };
  };

  networking.networkmanager.dns = "systemd-resolved";
}
