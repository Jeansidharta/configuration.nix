{ ... }:
{
  # users.users.sidharta.extraGroups = [ "docker" ];

  virtualisation = {
    podman = {
      enable = true;
      # daemon.settings = {
      #   ipv6 = true;
      #   fixed-cidr-v6 = "fd10::/80";
      #   metrics-addr = "0.0.0.0:9323";
      # };
    };
  };
}
