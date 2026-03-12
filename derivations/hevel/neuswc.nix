{
  bmake,
  eudev,
  fetchFromSourcehut,
  fontconfig,
  kdePackages,
  lib,
  libdrm,
  libinput,
  libxcb,
  libxcb-wm,
  libxkbcommon,
  neuwld,
  pixman,
  pkg-config,
  stdenv,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation rec {
  pname = "neuswc";
  version = "main";

  src = fetchFromSourcehut {
    owner = "~shrub900";
    repo = "neuswc";
    rev = version;
    hash = "sha256-2y7nKZKKWQaxJSuz5ia4VIcR4ibsAt/M6oqDy5jRpg4=";
  };

  nativeBuildInputs = [
    bmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    eudev
    fontconfig
    kdePackages.wayland-protocols
    libdrm
    libinput
    libxcb
    libxcb-wm
    libxkbcommon
    neuwld
    pixman
    wayland
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  patches = [ ./suid.patch ];

  meta = {
    description = "";
    homepage = "https://git.sr.ht/~shrub900/neuswc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "neuswc";
    platforms = lib.platforms.all;
  };
}
