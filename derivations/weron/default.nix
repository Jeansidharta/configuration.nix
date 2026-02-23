{
  lib,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:

buildGoModule rec {
  pname = "weron";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "pojntfx";
    repo = "weron";
    rev = "v${version}";
    hash = "sha256-17/mZtNppZOWhjlmJcU+uOjEHOMugCBAn9byj7LI67k=";
  };

  vendorHash = "sha256-THp5B7+NMDygdnxzsVlcR1ZdVYDDEZMp3sYLif2tLMA=";

  buildInputs = [
    libpcap
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Overlay networks based on WebRTC";
    homepage = "https://github.com/pojntfx/weron";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "weron";
  };
}
