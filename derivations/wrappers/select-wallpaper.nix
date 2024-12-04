{
  sxiv,
  wallpaper-manager,
  writeShellApplication,
}:

writeShellApplication {
  name = "wallpaper";
  runtimeInputs = [ sxiv ];
  text = ''
    ${wallpaper-manager}/bin/wallpaper-manager select-wallpaper
  '';
}
