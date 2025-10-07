{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland-zsock = {
      url = "github:Jeansidharta/hyprland-zsock";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      hyprland-zsock,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let

        pkgs = nixpkgs.legacyPackages.${system};
        package = pkgs.callPackage ./default.nix {
          inherit hyprland-zsock;
        };
      in
      {
        packages.default = package;
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.zig
            pkgs.zls
          ];
        };
      }
    );
}
