{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    sqlite-schema-diagram = {
      url = "git+https://gitlab.com/Screwtapello/sqlite-schema-diagram.git";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
      sqlite-schema-diagram,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {

        packages.default = pkgs.writeShellApplication {
          name = "sqlite-diagram";

          runtimeInputs = [
            pkgs.sqlite
            pkgs.graphviz
          ];

          text = ''
            dot -Tsvg <(sqlite3 "$1" -init "/nix/store/5g9gvv0xskjqbr1xjfpc1zvmy5c9h3vd-source/sqlite-schema-diagram.sql" "") > schema.svg
          '';
        };
      }
    );
}
