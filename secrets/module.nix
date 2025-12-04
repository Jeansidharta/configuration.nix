{
  config,
  lib,
  pkgs,
  ...
}:
{
  age.secrets.nix-github-token = {
    file = ./nix-github-token.age;
    owner = "sidharta";
  };
  age.secrets.wireguard-priv-key = lib.mkIf (config.networking.hostName == "obsidian") {
    file = ./wireguard.age;
  };
  age.secrets.nylon-key-obsidian = lib.mkIf (config.networking.hostName == "obsidian") {
    file = ./nylon-key-obsidian.age;
  };
  age.secrets.nylon-key-basalt = lib.mkIf (config.networking.hostName == "basalt") {
    file = ./nylon-key-basalt.age;
  };
  # age.secrets.nylon-key-graphite = {
  #   file = ./nylon-key-graphite.age;
  # };
}
