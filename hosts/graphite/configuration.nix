{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  networking.hostName = "graphite";
}
