{ ... }:
{
  users.users.sidharta.extraGroups = [
    "tor"
  ];
  services.tor = {
    enable = true;
    client.enable = true;
    # controlSocket.enable = true;
    settings = {
      ControlPort = 9051;
      HashedControlPassword = "16:DB07FBCA1CE2B6A360D7B98EF09D2877ECEE44B0750DD72DCFA3DE0263";
    };
  };
}
