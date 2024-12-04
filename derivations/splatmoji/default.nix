let
  pkgs = import <nixpkgs> { };
in
pkgs.callPackage (import ./derivation.nix) {
  splatmojiSource = pkgs.fetchFromGitHub {
    owner = "cspeterson";
    repo = "splatmoji";
    rev = "b8d14b411c8076184e8bc872336ab7599b8b2ced";
    sha256 = "sha256-MMXkX93i6AV/Lze/LwmkrjaM68feMmnRjpV/lWH85zA=";
  };
}
