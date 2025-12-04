let
  keys = import ../ssh-pubkeys.nix;

  allPublicKeys = [
    keys.obsidian.system
    keys.phone
    keys.basalt.system
    # keys.graphite.system
    # keys.goldfish.system
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
}
