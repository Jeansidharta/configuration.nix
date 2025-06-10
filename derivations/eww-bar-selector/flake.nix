{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    zig-flake.url = "github:mitchellh/zig-overlay";
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
      zig-flake,
      hyprland-zsock,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        project_name = "bar-selector";
        version = "0.0.1";
        deps = {
          hyprland-zsock = hyprland-zsock;
        };

        pkgs = nixpkgs.legacyPackages.${system};
        # zig = zig-flake.outputs.packages.${system}.master;
        zig = pkgs.zig;
        mkLibsLinkScript = ''
          rm --force libs
          ln -s ${pkgs.linkFarm (project_name + "-deps") deps} libs
        '';
        package = pkgs.stdenv.mkDerivation {
          pname = project_name;
          version = version;
          src = ./.;
          buildInputs = [
            zig
          ];

          buildPhase = ''
            cp --no-preserve=mode $src/* . -r
            ${mkLibsLinkScript}

            zig build \
              --prefix $out \
              --release=safe \
              -Doptimize=ReleaseSafe \
              -Ddynamic-linker=$(cat $NIX_BINTOOLS/nix-support/dynamic-linker) \
              --cache-dir cache \
              --global-cache-dir global \
              --summary all
          '';
        };
      in
      {
        packages.default = package;
        devShell = pkgs.mkShell {
          shellHook = mkLibsLinkScript;
          buildInputs = [
            zig
          ];
        };
      }
    );
}
