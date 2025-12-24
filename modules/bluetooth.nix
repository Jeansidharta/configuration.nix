{ options, lib, ... }:

let
  hm-module =
    { ... }:
    lib.mkMerge [
      (lib.optionalAttrs (options ? programs.elephant) {
        programs.elephant.providers = [ "bluetooth" ];
      })
    ];
in
lib.mkMerge [
  {
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    services.blueman.enable = true;
  }
  (lib.optionalAttrs (options ? home-manager) {
    home-manager.users.sidharta.imports = [ hm-module ];
  })
]
