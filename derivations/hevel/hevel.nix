{
  lib,
  stdenv,
  fetchFromSourcehut,
  wayland,
  pkg-config,
  wayland-scanner,
  neuswc,
  neuwld,
  libinput,
  libxkbcommon,
  pixman,
  libdrm,
  fontconfig,
  libxcb,
  libxcb-wm,
}:

stdenv.mkDerivation rec {
  pname = "hevel";
  version = "main";

  src = fetchFromSourcehut {
    owner = "~dlm";
    repo = "hevel";
    rev = version;
    hash = "sha256-M8X+bE3EM/vpUyLIyQ0TIRAhiTR+u8UL2/niqV4gUdY=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  patches = [ ./hevel-config.patch ];

  buildInputs = [
    wayland
    neuswc
    neuwld
    libinput
    libxkbcommon
    pixman
    fontconfig
    libxcb
    libxcb-wm
    libdrm
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "";
    homepage = "https://git.sr.ht/~dlm/hevel";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hevel";
    platforms = lib.platforms.all;
  };
}
