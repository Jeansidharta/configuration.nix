{
  config,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.moonlight-qt
  ];

  services.sunshine = {
    enable = true;
    openFirewall = true;
    settings = {
      sunshine_name = config.networking.hostName;
    };
  };
}