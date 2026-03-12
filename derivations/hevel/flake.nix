{
  inputs = { };
  outputs =
    { nixpkgs, ... }:
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
        { pkgs, ... }:
        let
          neuwld = pkgs.callPackage (import ./neuwld.nix) { };
          neuswc = pkgs.callPackage (import ./neuswc.nix) { inherit neuwld; };
        in
        {
          inherit neuswc;
          default = pkgs.callPackage (import ./hevel.nix) { inherit neuwld neuswc; };
        }
      );
    };
}