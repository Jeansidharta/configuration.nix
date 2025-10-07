{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        packages.default = pkgs.writeShellScriptBin "backlight" ''
          PATH=$PATH:${pkgs.light}/bin
          ${naersk-lib.buildPackage ./.}/bin/backlight "$@"
        '';
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cargo
              rustc
              rustfmt
              pre-commit
              rustPackages.clippy
              light
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;
          };
      }
    );
}
