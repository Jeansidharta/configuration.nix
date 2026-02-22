{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage (import ../derivations/weron/default.nix) { })
  ];
}
