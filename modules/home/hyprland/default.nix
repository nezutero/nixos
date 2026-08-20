{ config, ... }:

{
  xdg.configFile."hypr".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nixos/modules/home/hyprland/config";
}
