{ ... }:
{
  networking.networkmanager.enable = true;
  users.users.sidharta = {
    extraGroups = [
      "networkmanager"
    ];
  };
}
