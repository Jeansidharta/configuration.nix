# A derivation providing Radxa's vendor u-boot for the Radxa Zero.
{ stdenv, ... }:
stdenv.mkDerivation {
  name = "radxa-zero-vendor-uboot";
  version = "0.1";
  phases = [ "installPhase" ];
  src = builtins.fetchurl {
    url = "https://dl.radxa.com/zero/images/loader/u-boot.bin.sd.bin";
    sha256 = "720603d57501a152a5b7293b54e042619b72b3e77a13a62d9a95aa6f8e292248";
  };
  installPhase = "install -D -m 0755 $src $out/u-boot.bin";
}
