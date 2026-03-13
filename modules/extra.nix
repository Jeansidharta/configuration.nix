{ ... }:
{
  home-manager.users.sidharta.imports = [
    (
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          # Leave this in extras, since it causes a ffmpeg compilation on ARM
          yt-dlp # Download youtube videos
          transmission_4 # Bit torrent client
        ];
      }
    )
  ];
}
