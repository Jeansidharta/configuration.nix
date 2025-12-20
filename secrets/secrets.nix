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
  "wireguard.age".publicKeys = [
    keys.obsidian.sidharta
    keys.obsidian.system
  ];
  "wireguard-max.age".publicKeys = [
    keys.obsidian.sidharta
    keys.obsidian.system
  ];

  "nylon-key-obsidian.age".publicKeys = [
    keys.obsidian.system
    keys.obsidian.sidharta
  ];
  "nylon-key-graphite.age".publicKeys = [
    keys.graphite.system
    keys.graphite.sidharta
  ];
  "nylon-key-basalt.age".publicKeys = [
    keys.basalt.system
    keys.basalt.sidharta
  ];
  "nylon-key-vivianite.age".publicKeys = [
    keys.vivianite.system
    keys.vivianite.sidharta
  ];
  "nylon-key-fixie.age".publicKeys = [
    keys.vivianite.system
    keys.vivianite.sidharta
  ];
  "nylon-key-calcite.age".publicKeys = [
    keys.calcite.system
    keys.calcite.sidharta
  ];
}
