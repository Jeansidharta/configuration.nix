{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

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
        zig = pkgs.zig;
        mkLibsLinkScript = ''
          mkdir -p libs
          rm --force libs/hyprland-zsock
          ln -s ${hyprland-zsock} libs/hyprland-zsock
        '';
        package = pkgs.stdenv.mkDerivation {
          name = "workspaces-report";
          version = "0.0.1";
          src = ./.;
          buildInputs = [
            zig
            pkgs.which
          ];

          buildPhase = ''
            echo "custom build phase"
            cd $TEMP
            cp --no-preserve=mode $src/* . -r
            ${mkLibsLinkScript}

            zig build \
              --prefix $out \
              --release=safe \
              -Doptimize=Debug \
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
