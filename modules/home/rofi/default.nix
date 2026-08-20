{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    location = "center";
    terminal = "foot";
    
    extraConfig = {
      modi = "drun";
      show-icons = false;
      display-drun = " ";
    };

    theme = builtins.readFile ./theme.rasi;
  };
}

