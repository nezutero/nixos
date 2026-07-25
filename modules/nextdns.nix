{ config, pkgs, ... }:
{
  sops.defaultSopsFile = ../secrets/nextdns.yaml;
  sops.age.keyFile = "/home/nezutero/.config/sops/age/keys.txt";
  sops.secrets.nextdns_id = { };

  environment.systemPackages = [ pkgs.nextdns ];

  systemd.services.nextdns = {
    description = "NextDNS DoH proxy";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      LoadCredential = "nextdns_id:${config.sops.secrets.nextdns_id.path}";
      ExecStart = "${pkgs.writeShellScript "nextdns-run" ''
        ID=$(cat "$CREDENTIALS_DIRECTORY/nextdns_id")
        exec ${pkgs.nextdns}/bin/nextdns run -config "$ID" -cache-size 10MB
      ''}";
      Restart = "on-failure";
    };
  };

  systemd.services.nextdns-activate = {
    description = "Activate NextDNS";
    script = "${pkgs.nextdns}/bin/nextdns activate";
    after = [ "nextdns.service" ];
    wantedBy = [ "multi-user.target" ];
  };

  networking.nameservers = [ "127.0.0.1" "::1" ];
  networking.networkmanager.dns = "none";
}
