{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../options/nylon-wg.nix
  ];

  services.nylon-wg = {
    enable = true;
    centralConfig = "/var/nylon/central.yaml";
    node = {
      id = config.networking.hostName;
      logPath = "/var/nylon/log";
      key = config.age.secrets.${"nylon-key-" + config.networking.hostName}.path;
    };
  };
}
