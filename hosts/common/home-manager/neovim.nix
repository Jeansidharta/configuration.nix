{ config, pkgs, ... }:
{
  enable = true;
  defaultEditor = true;
  vimAlias = true;
  viAlias = true;

  extraWrapperArgs = [
    "--suffix"
    "LD_LIBRARY_PATH"
    ":"
    "${pkgs.lib.makeLibraryPath [
      # Needed for plugin neoclip
      pkgs.sqlite
    ]}"
  ];
}
