{ lib, ssh-pubkeys, ... }:
let
  inherit (builtins) typeOf attrValues;
  inherit (lib) mapAttrsToList flatten;

  makeHostKeys =
    hostname: keyset: if typeOf keyset == "string" then [ keyset ] else attrValues keyset;

  # Generates a list of keys of all hosts
  keys = flatten (mapAttrsToList makeHostKeys ssh-pubkeys);
in
{
  users.users.sidharta.openssh.authorizedKeys.keys = keys;
}
