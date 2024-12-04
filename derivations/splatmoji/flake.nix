{
  inputs = {
    splatmojiSource.url = "github:cspeterson/splatmoji/master";
    splatmojiSource.flake = false;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      splatmojiSource,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.callPackage (import ./derivation.nix) { inherit splatmojiSource; };
      }
    );
}
