{
  stdenv,
  zig,
  linkFarm,
  hyprland-zsock,
  eww,
}:
let
  deps = {
    hyprland-zsock = hyprland-zsock;
  };
  mkLibsLinkScript = ''
    rm --force libs
    ln -s ${linkFarm ("bar-selector-deps") deps} libs
  '';

in
stdenv.mkDerivation {
  pname = "bar-selector";
  version = "0.0.1";
  src = ./.;
  buildInputs = [
    zig
    eww
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
}
