{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  time.timeZone = "US/Eastern";
  networking.hostName = "obsidian";
}
