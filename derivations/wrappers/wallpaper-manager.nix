{
  writeShellApplication,
  sxiv,
  mpv,
  xwinwrap,
  ffmpeg,
  package,
}:

writeShellApplication {
  name = "wallpaper-manager";
  runtimeInputs = [
    sxiv
    mpv
    xwinwrap
    ffmpeg
  ];
  text = ''
    ${package}/bin/wallpaper-manager "$@"
  '';
}
