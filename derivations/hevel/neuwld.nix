{
  lib,
  stdenv,
  fetchFromSourcehut,
  bmake,
  pkg-config,
  fontconfig,
  pixman,
  libdrm,
  wayland,
  wayland-scanner,
  freetype,
}:

stdenv.mkDerivation rec {
  pname = "neuwld";
  version = "main";

  src = fetchFromSourcehut {
    owner = "~shrub900";
    repo = "neuwld";
    rev = version;
    hash = "sha256-0+rgWrefh19bBEmcqw0Lal1PHkendtCkQ2EIg+LHb74=";
  };

  nativeBuildInputs = [
    bmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    fontconfig
    pixman
    libdrm
    wayland
    freetype
  ];

  outputs = [
    "out"
    "dev"
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "";
    homepage = "https://git.sr.ht/~shrub900/neuwld";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "neuwld";
    platforms = lib.platforms.all;
  };
}
