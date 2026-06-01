{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  forHost = hostname: data: if (config.networking.hostName == hostname) then data else { };

  forBasalt = forHost "basalt";
  forObsidian = forHost "obsidian";
  forGraphite = forHost "graphite";
  forVivianite = forHost "vivianite";
  forFixie = forHost "fixie";
  forCalcite = forHost "calcite";
in
{
  imports = [ inputs.agenix.nixosModules.default ];
  environment.systemPackages = with pkgs; [
    agenix
  ];
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-github-token.path}
    allow-import-from-derivation = true
  '';
  nixpkgs.overlays = [
    (config.lib.overlay-helpers.overlay-flake "agenix")
  ];
  age.secrets = {
    nix-github-token = {
      file = ./nix-github-token.age;
      owner = "sidharta";
    };
    coffee-psk = {
      file = ./coffee-psk.age;
      owner = "sidharta";
    };
    wifi = {
      file = ./wifi.age;
    };
    weron-base-password = {
      file = ./weron-base-password.age;
    };
    weron-base-key = {
      file = ./weron-base-key.age;
    };
  }
  // (forBasalt {
    netlify-ddns = {
      file = ./netlify-ddns.age;
      owner = "sidharta";
    };
  })
  // (forObsidian {
    wg-lsbots-key = {
      file = ./wg-lsbots-key-obsidian.age;
    };
  })
  // (forGraphite {
    wg-lsbots-key = {
      file = ./wg-lsbots-key-graphite.age;
    };
  });
}
