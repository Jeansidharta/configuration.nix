let
  graphite = {
    system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5TwFvhFpbcI1h7LAdC1FPo7Y/nYfwqYVjpZ0Ns9N7+";
    sidharta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDig6qJstpy9HOVdJkvhc15ywIdRwUiH5uZ7lbwNW0rZ";
  };

  allPublicKeys = [
    graphite.system
    graphite.sidharta
  ];
in
{
  "github-personal-access-token.age".publicKeys = allPublicKeys;
}
