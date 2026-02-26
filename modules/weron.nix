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
    vpn-ip.base = {
      enable = true;
      passwordFile = config.age.secrets.weron-base-password.path;
      keyFile = config.age.secrets.weron-base-key.path;
      community = "sidharta-devices";
    };
  };
}
