{
  config,
  lib,
  pkgs,
  ...
}:
let
  forHost = hostname: lib.mkIf (config.networking.hostName == hostname);

  forBasalt = forHost "basalt";
  forObsidian = forHost "obsidian";
  forGraphite = forHost "graphite";
  forVivianite = forHost "vivianite";
  forFixie = forHost "fixie";
in
{
  age.secrets.nix-github-token = {
    file = ./nix-github-token.age;
    owner = "sidharta";
  };
  age.secrets.wireguard-priv-key = forObsidian {
    file = ./wireguard.age;
  };
  age.secrets.nylon-key-obsidian = forObsidian {
    file = ./nylon-key-obsidian.age;
  };
  age.secrets.nylon-key-basalt = forBasalt {
    file = ./nylon-key-basalt.age;
  };
  age.secrets.nylon-key-graphite = forGraphite {
    file = ./nylon-key-graphite.age;
  };
  age.secrets.nylon-key-vivianite = forVivianite {
    file = ./nylon-key-vivianite.age;
  };
  age.secrets.nylon-key-fixie = forFixie {
    file = ./nylon-key-fixie.age;
  };
}
