{ inputs, pkgs, lib, ... }:
{
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.activation.zenBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ZEN_PROFILE="$HOME/.config/zen/zr7hisqa.Default Profile"

    if [ -d "$ZEN_PROFILE" ]; then
      mkdir -p "$ZEN_PROFILE/chrome"

      ln -sf "$HOME/dotfiles/other/zen/user.js" \
        "$ZEN_PROFILE/user.js"

      ln -sf "$HOME/dotfiles/other/zen/chrome/userChrome.css" \
        "$ZEN_PROFILE/chrome/userChrome.css"
    fi
  '';
}
