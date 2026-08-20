{ ... }:

{
  networking.networkmanager.enable = true;

  services.resolved.enable = false;

  # networking.nameservers = [
  #   "extended.dns.mullvad.net"
  #   "194.242.2.6"
  # ];
}
