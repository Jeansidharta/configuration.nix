{ ... }:
{
  users.users.sidharta.extraGroups = [
    "tor"
  ];
  services.tor = {
    enable = true;
    client.enable = true;
  };
  home-manager.users.sidharta.imports = [
    (
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.torsocks
        ];
      }
    )
  ];
}
