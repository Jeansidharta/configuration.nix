{
  stdenv,
  lib,
  fetchFromGitLab,
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

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "drawy";
    domain = "invent.kde.org";
    rev = "master";
    sha256 = "sha256-4uidKuoG40o0l/UKa7wtac5yvl9cvk+uTVhdSwFGyOw=";
  };

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

    for desktop_file in "$desktopItem/share/applications/*"; do
      install -Dm644 $desktop_file $out/share/applications/$(basename $desktop_file)
    done

    install -Dm644 ${src}/assets/logo-256.png $out/share/icons/hicolor/256x256/apps/drawy.png
    install -Dm644 ${src}/assets/logo-512.png $out/share/icons/hicolor/512x512/apps/drawy.png
    install -Dm644 ${src}/assets/mime-32.png $out/share/icons/hicolor/32x32/apps/drawy.png
    install -Dm644 ${src}/assets/mime-64.png $out/share/icons/hicolor/64x64/apps/drawy.png
    install -Dm644 ${src}/assets/mime.svg $out/share/icons/hicolor/scalable/apps/drawy.svg

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
