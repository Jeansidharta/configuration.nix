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
  age.secrets.rede-mesh-psk = {
    file = ./rede-mesh-psk.age;
    owner = "sidharta";
  };
}
