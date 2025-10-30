{
  splatmoji,
  nixpkgs-unstable,
  neovim-with-plugins,
  plover-flake,
  sqlite-diagram-flake,
}:

[
  (
    final: prev:
    let
      system = prev.system;
      rawPkgsUnstable = nixpkgs-unstable.legacyPackages.${system};

      plover = plover-flake.packages.${system}.plover;
      sqlite-diagram = sqlite-diagram-flake.packages.${system}.default;
    in
    {
      inherit plover;
      pkgsUnstable = rawPkgsUnstable;
      splatmoji = splatmoji.packages.${system}.default;
      mypkgs = {
        inherit
          sqlite-diagram
          ;
        neovim = neovim-with-plugins.packages.${system}.base.override (prev: {
          extraPackages = [
            prev.nil
            prev.prettierd
            prev.nodePackages_latest.bash-language-server
            prev.ripgrep
            prev.unixtools.xxd
            prev.marksman
            prev.zk
            prev.nixfmt-rfc-style
          ];
        });
      };
    }
  )
]
