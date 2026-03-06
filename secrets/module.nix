{
  config,
  lib,
  inputs,
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
  age.secrets.nix-github-token = {
    file = ./nix-github-token.age;
    owner = "sidharta";
  };
  age.secrets.coffee-psk = {
    file = ./coffee-psk.age;
    owner = "sidharta";
  };
  age.secrets.netlify-ddns = forBasalt {
    file = ./netlify-ddns.age;
    owner = "sidharta";
  };
  age.secrets.wifi = {
    file = ./wifi.age;
  };
  age.secrets.weron-base-password = {
    file = ./weron-base-password.age;
  };
  age.secrets.weron-base-key = {
    file = ./weron-base-key.age;
  };
}
