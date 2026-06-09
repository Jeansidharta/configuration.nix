let
  keys = import ../ssh-pubkeys.nix;

  allPublicKeys = [
    keys.obsidian.system
    keys.obsidian.sidharta
    keys.phone
    keys.basalt.system
    keys.basalt.sidharta
    keys.graphite.system
    keys.graphite.sidharta
    keys.vivianite.sidharta
    keys.vivianite.system
    keys.calcite.system
    keys.calcite.sidharta
  ];
in
{
  "nix-github-token.age".publicKeys = allPublicKeys;
  "coffee-psk.age".publicKeys = allPublicKeys;

  "weron-base-password.age".publicKeys = allPublicKeys;
  "weron-base-key.age".publicKeys = allPublicKeys;
  "wifi.age".publicKeys = allPublicKeys;
  "wg-lsbots-key-obsidian.age".publicKeys = [
    keys.obsidian.system
    keys.obsidian.sidharta
  ];
  "wg-lsbots-key-basalt.age".publicKeys = [
    keys.basalt.sidharta
    keys.basalt.system
  ];
  "wg-lsbots-key-graphite.age".publicKeys = [
    keys.graphite.sidharta
    keys.graphite.system
  ];
  "netlify-ddns.age".publicKeys = [
    keys.basalt.system
    keys.basalt.sidharta
    keys.obsidian.system
    keys.obsidian.sidharta
  ];
}
