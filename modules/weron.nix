{ pkgs, config, ... }:
{
  imports = [ (import ../options/weron.nix) ];

  nixpkgs.overlays = [
    (final: prev: {
      weron = (prev.callPackage (import ../derivations/weron/default.nix) { });
    })
  ];

  environment.systemPackages = [ pkgs.weron ];

  services.weron = {
    enable = true;
    open-firewall = true;
    vpn-ip.base = {
      enable = true;
      verbose = "7";
      passwordFile = config.age.secrets.weron-base-password.path;
      keyFile = config.age.secrets.weron-base-key.path;
      dev = "weron-base";
      community = "sidharta-devices";
    };
  };
}
