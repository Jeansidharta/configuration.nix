{
  main-user,
  ...
}:
{
  imports = [
    ./hosts/common.nix
  ] ++ import ./modules/default.nix;

  home.username = main-user;
  home.homeDirectory = "/home/${main-user}";
}
