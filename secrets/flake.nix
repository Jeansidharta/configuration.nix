{
  inputs =
    {
    };
  outputs =
    {
      self,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        sidharta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDig6qJstpy9HOVdJkvhc15ywIdRwUiH5uZ7lbwNW0rZ";
        system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFUJpSJe6cceGqXjKuUiWLpYodzYKCKSihwiTIpSejW";

        allKeys = [
          sidharta
          system
        ];
      in
      {
        "userPassword.age".publicKeys = allKeys;
        "githubToken.age".publicKeys = allKeys;
      }
    );
}
