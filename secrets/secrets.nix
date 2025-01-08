let
  graphite = {
    system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFEVFzY+b9v9M2zY3qOUCnsHdEcOnhERQB0jeyAkg80a";
    sidharta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDig6qJstpy9HOVdJkvhc15ywIdRwUiH5uZ7lbwNW0rZ";
  };

  allPublicKeys = [
    graphite.system
    graphite.sidharta
  ];
in
{
  "nix-github-token.age".publicKeys = allPublicKeys;
}
