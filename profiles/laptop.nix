{ ... }:
{
  imports = [
    ../modules/common/default.nix
    ../modules/desktop/default.nix
    ../modules/nylon-wg.nix
    ../modules/network-manager.nix
    ../modules/nix-extra.nix
    ../modules/docker.nix
    ../modules/tor.nix
    ../modules/bluetooth.nix
    ../modules/ssh-authorized-keys.nix
    ../secrets/module.nix
    ../containers/default.nix
  ];
  services.auto-cpufreq.enable = true;
}
