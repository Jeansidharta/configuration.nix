{
  stdenv,
  xdotool,
  rofi,
  xsel,
  jq,

  splatmojiSource,
}:

let
  dataDir = "$src/data";
  configFile = "$out/etc/splatmoji.config";
  libDir = "$out/lib";
  rofiExe = "${rofi}/bin/rofi";
  xdotoolExe = "${xdotool}/bin/xdotool";
  xselExe = "${xsel}/bin/xsel";
  jqExe = "${jq}/bin/jq";
in

stdenv.mkDerivation {
  name = "splatmoji-1.2.0";
  src = splatmojiSource;
  patches = [ ./path-fix.patch ];
  postPatch = ''
    substituteInPlace ./splatmoji.config \
      --replace-fail @rofi@ ${rofiExe} \
      --replace-fail @xdotool@ ${xdotoolExe} \
      --replace-fail @xsel@ ${xselExe}

    substituteInPlace ./splatmoji \
      --replace-fail @LIB_DIR@ ${libDir} \
      --replace-fail @rofi@ ${rofiExe} \
      --replace-fail @xdotool@ ${xdotoolExe} \
      --replace-fail @xsel@ ${xselExe}

    substituteInPlace ./lib/functions \
      --replace-fail @DATA_DIR@ ${dataDir} \
      --replace-fail @CONFIG_FILE@ ${configFile} \
      --replace-fail @jq@ ${jqExe}
  '';
  installPhase = ''
    mkdir $out/bin -p
    mkdir $out/lib -p
    mkdir $out/etc -p
    mv ./splatmoji $out/bin
    mv ./splatmoji.config ${configFile}
    mv ./lib/functions ${libDir}/functions
  '';
}
