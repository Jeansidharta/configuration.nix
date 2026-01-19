src:
{
  stdenv,
  lib,
  shared-mime-info,
  makeDesktopItem,
  cmake,
  kdePackages,
  pkg-config,
  qt6,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "drawy";
  version = "1.0.0-alpha";

  inherit src;

  desktopItem = makeDesktopItem {
    name = "Drawy";
    exec = "drawy";
    icon = "drawy";
    comment = meta.description;
    desktopName = "Drawy";
    genericName = "Drawy";
    categories = [ "Graphics" ];
  };

  nativeBuildInputs = [
    cmake
    zstd.dev
    pkg-config
    kdePackages.plasma5support
    kdePackages.wrapQtAppsHook
    kdePackages.extra-cmake-modules
    shared-mime-info.dev
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
  ];

  configurePhase = ''
    runHook preConfigure

    cmake -B "$TEMP" -S "$src" -DCMAKE_BUILD_TYPE=Release

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    cmake --build "$TEMP" --config Release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir "$out"
    cmake --install "$TEMP" --prefix "$out"

    runHook postInstall
  '';

  postFixup = ''
    patchelf --add-rpath "$out/lib" "$out/bin/.drawy-wrapped"
  '';

  meta = with lib; {
    description = "Your handy, infinite, brainstorming tool";
    mainProgram = "drawy";
    maintainers = with maintainers; [ ];
    homepage = "https://github.com/Prayag2/drawy";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
