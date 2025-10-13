{
  writeScriptBin,
  writeText,
  runCommand,
  lib,

  backlight,
  volume-watcher,
  window-title-watcher,
  workspaces-report,
  eww-bar-selector,
  envsub,

  bash,
  eww,
  pulseaudio,
  pamixer,
  playerctl,
  systemd,
  rofi-unwrapped,
  findutils,

  extra-runtime-deps ? [ ],
  extra-variables ? { },
  extra-files ? { },
}:
let

  runtime-deps = [
    bash
    backlight
    volume-watcher
    window-title-watcher
    workspaces-report
    eww-bar-selector

    pulseaudio
    pamixer
    playerctl
    systemd
    rofi-unwrapped
    findutils
  ];

  extra-files-derivation = lib.mapAttrs writeText extra-files;
  copyCommandExtraFiles = lib.concatMapStringsSep "\n" (
    file: "cp --no-preserve=mode ${file} $out/${file.name}"
  ) (lib.attrValues extra-files-derivation);
  configDir = runCommand "eww-config" ({ } // extra-variables) ''
    cp -r --no-preserve=mode ${./config} $out
    ${copyCommandExtraFiles}
    find $out/ -type f -exec bash -c "cat {} | ${lib.getExe envsub} -p @ -s @ > {}.tmp && mv {}.tmp {}" \;
  '';
in

writeScriptBin "eww" ''
  export PATH="${lib.makeBinPath (runtime-deps ++ extra-runtime-deps)}:$PATH"
  ${lib.getExe eww} --config ${configDir} "$@"
''
