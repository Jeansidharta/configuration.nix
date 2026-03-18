{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  eudev,
  seatd,
  libdisplay-info,
  libxkbcommon,
  libgbm,
  libinput,

  wayland,
  libGL,
}:

rustPlatform.buildRustPackage rec {
  pname = "driftwm";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "malbiruk";
    repo = "driftwm";
    rev = "v${version}";
    hash = "sha256-0Vi/3LauL2oElyTQHWv0h1LCcVf80cVJf65Hs3bwEbw=";
  };

  cargoHash = "sha256-Orn6rmdfeudSpeil6ZIS+iiMFFDMjO0p026A/zm7r8Q=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    eudev
    seatd
    libdisplay-info
    libxkbcommon
    libgbm
    libinput
    wayland
  ];

  postFixup = ''
    patchelf --add-needed ${wayland}/lib/libwayland-client.so $out/bin/driftwm
    patchelf --add-needed ${wayland}/lib/libwayland-egl.so $out/bin/driftwm
    patchelf --add-needed ${libGL}/lib/libEGL.so $out/bin/driftwm
  '';

  meta = {
    description = "A trackpad-first infinite canvas Wayland compositor";
    homepage = "https://github.com/malbiruk/driftwm";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "driftwm";
  };
}
