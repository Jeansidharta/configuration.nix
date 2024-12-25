{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
    envsub.url = "github:stephenc/envsub";
    envsub.flake = false;
  };
  outputs =
    {
      utils,
      nixpkgs,
      envsub,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "envsub";
          version = "0.1.3";
          src = envsub;
          cargoHash = "sha256-gUK7vkmXCN9BlBo0JRJ6iCWDlfdxiVFjPp9Fs0cDKV0=";

          meta = {
            description = "substitutes the values of environment variables";
            homepage = "https://github.com/stephenc/envsub";
            license = pkgs.lib.licenses.mit;
            maintainers = [ ];
          };
        };
      }
    );
}
