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
  "rede-mesh-psk.age".publicKeys = allPublicKeys;
}
