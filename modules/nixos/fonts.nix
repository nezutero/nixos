{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-cjk-sans
      nerd-fonts.jetbrains-mono
      jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Inter" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
  };
}
