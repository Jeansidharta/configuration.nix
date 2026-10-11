{ pkgs, lib, ... }:
{
  home.username = "sidharta";
  home.homeDirectory = "/home/sidharta";
  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.dank-material-shell.settings.lockBeforeSuspend = lib.mkForce false;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "nb" = {
        HostName = "192.168.0.118";
        User = "sidharta";
        port = 22;
      };
      "rpi" = {
        HostName = "192.168.0.210";
        User = "sidharta";
        Port = 22;
      };
      "graphite" = {
        HostName = "192.168.0.186";
        User = "sidharta";
        Port = 22;
      };
      "opal" = {
        HostName = "opal.sidharta.xyz";
        User = "sidharta";
        port = 22;
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
  home.packages = [ ];
}
