{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  };
  outputs =
    { ... }:
    {
      homeConfigurations.default =
        { pkgs, ... }:
        {
          imports = [
            ./hyprland-hm.nix
            ./hypridle-hm.nix
          ];
        };
      nixosConfigurations.default =
        { pkgs, ... }:
        {
          imports = [
            ./hyprland.nix
          ];
        };
    };
}
