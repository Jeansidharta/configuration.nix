{ ... }:
{
  home-manager.users.sidharta.imports = [
    (
      { pkgs, lib, ... }:
      {
        home.packages = with pkgs; [
          # Leave this in extras, since it causes a ffmpeg compilation on ARM
          yt-dlp # Download youtube videos
          lmms # Music production
          inkscape # Vector image editor
          imhex # A very nice hex editor
          libreoffice # Office suite
          hyprpicker # Cool color picker
          transmission_4 # Bit torrent client
          zapzap # whatsapp client
          obsidian # Note taking app
        ];
      }
    )
  ];
}
