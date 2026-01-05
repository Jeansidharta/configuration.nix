{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../options/nylon-wg.nix
  ];

  environment.systemPackages = [
    pkgs.nylon-wg
  ];

  nixpkgs.overlays = [
    (final: prev: {
      nylon-wg =
        inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.callPackage
          (import ../derivations/nylon-wg.nix)
          { };
    })
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
