{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  home-manager.users.sidharta.imports = [
    inputs.nix-index-database.outputs.homeModules.default
    {
      programs.nix-index.symlinkToCacheHome = true;
    }
  ];
  nixpkgs.overlays = [ inputs.nix-index-database.outputs.overlays.nix-index ];
  programs.nix-index-database.comma.enable = true;
}
