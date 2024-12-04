{
  hostname,
  main-user,
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${main-user} = import ./home.nix;
    extraSpecialArgs = {
      inherit hostname main-user;
    };
  };
}
