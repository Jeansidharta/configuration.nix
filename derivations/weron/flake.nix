{
  inputs = {
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      nix2container,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs (nixpkgs.lib.systems.flakeExposed) (
          system:
          f {
            inherit system;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs, system, ... }:
        let
          nix2containerPkgs = nix2container.packages.${system};
          setup = pkgs.writeScriptBin "setup" ''
            #!/bin/sh
            weron signaler
          '';
        in
        {
          default = nix2containerPkgs.nix2container.buildImage {
            name = "weron-signaler";
            tag = "latest";
            maxLayers = 120;
            copyToRoot = pkgs.buildEnv {
              name = "root";
              paths = [
                pkgs.busybox
                (pkgs.callPackage (import ./default.nix) { })
                pkgs.dockerTools.fakeNss
                setup
              ];
              pathsToLink = [
                "/bin"
                "/etc"
              ];
            };
            config = {
              ExposedPorts = {
                "1337" = null;
              };
              Entrypoint = [ "/bin/setup" ];
            };
          };
        }
      );
    };
}
