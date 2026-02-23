{ pkgs, ... }:
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

    vpn-mode = "ethernet";
    key = "batata";
    password = "tomate";
    community = "community-of-sidharta";
    # ips = [ "fd00::/112" ];
  };
}
