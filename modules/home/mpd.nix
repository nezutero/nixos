{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/nezutero/music";

    extraConfig = ''
      restore_paused "no"

      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';

    network.listenAddress = "127.0.0.1";
    network.port = 6600;
  };

  programs.rmpc.enable = true;
}
