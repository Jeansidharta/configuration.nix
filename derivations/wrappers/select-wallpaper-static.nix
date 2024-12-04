{
  sxiv,
  wallpaper-manager,
  writeShellApplication,
}:

writeShellApplication {
  name = "wallpaper-static";
  runtimeInputs = [ sxiv ];
  text = ''
    ${wallpaper-manager}/bin/wallpaper-manager --wallpapers-dir=/home/sidharta/wallpapers/static select-wallpaper --static
  '';
}
