{ lib, ssh-pubkeys, ... }:
let
  inherit (builtins) typeOf attrValues;
  inherit (lib) mapAttrsToList flatten;

  makeHostKeys =
    hostname: keyset: if typeOf keyset == "string" then [ keyset ] else attrValues keyset;

  # Generates a list of keys of all hosts
  user-keys = flatten (mapAttrsToList makeHostKeys ssh-pubkeys);

  # Generate a list of only system keys
  system-keys = flatten (
    mapAttrsToList (hostname: keyset: if keyset ? system then [ keyset.system ] else [ ]) ssh-pubkeys
  );
in
{
  users.users.sidharta.openssh.authorizedKeys.keys = user-keys;
  users.users.root.openssh.authorizedKeys.keys = system-keys;

  services.openssh.settings = {
    AllowUsers = [
      "root"
    ];
  };
}
