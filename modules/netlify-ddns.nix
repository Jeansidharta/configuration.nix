{
  pkgs,
  lib,
  config,
  ...
}:
let
  nddns = pkgs.callPackage (import ../derivations/netlify-ddns/default.nix) { };
  nddns-bin = lib.getExe' nddns "netlify-ddns";
in
{

  environment.systemPackages = [
    nddns
  ];

  systemd.user.services.netlify-ddns = {
    enable = true;
    description = "Netlify ddns";
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${nddns-bin}";
      LoadCredential = "env:${config.age.secrets.netlify-ddns.path}";
      EnvironmentFile = config.age.secrets.netlify-ddns.path;
      User = "sidharta";
      Restart = "no";
    };
  };

  systemd.user.timers.netlify-ddns = {
    timerConfig = {
      OnBootSec = "1s";
      OnUnitActiveSec = "2h";
    };
    wantedBy = [ "timers.target" ];
  };
}