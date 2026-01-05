{ lib, pkgs, ... }:
let
  mkNylonContainer =
    container-name: ip_addr: container-config:
    let
      nylon-name = "nylon-${container-name}";
    in
    {
      systemd.services."container@${container-name}" = {
        unitConfig = {
          BindsTo = [ "${nylon-name}.service" ];
          After = [ "${nylon-name}.service" ];
        };
      };

      systemd.services.${nylon-name} = {
        unitConfig = {
          Description = "Nylon's instance for the ${container-name} container";
        };
        serviceConfig =
          let
            yaml = pkgs.formats.yaml { };
            node-config = yaml.generate "${nylon-name}.yaml" {
              id = container-name;
              logPath = "/var/log/nylon/${container-name}";
              key = "0Hyl1Tym3IXcbferQaxdZO8qjd0ktUTY1gDEHCHigF0=";
              port = 57176;
              interfacename = "${nylon-name}";
              nonetconfigure = false;
              usesystemrouting = false;
              disablerouting = false;
            };
            central-config = yaml.generate "${nylon-name}-central.yaml" {
              routers = [
                {
                  id = container-name;
                  pubkey = "k4zzSxYIOm+u2gKQqdVoa6UTjmSFKfV7PonmKSe4u1M=";
                  address = ip_addr;
                }
              ];
              timestamp = 174083296220930900;
            };
            nylon = lib.getExe pkgs.nylon-wg;
            bash = lib.getExe pkgs.bash;
            ip = lib.getExe' pkgs.iproute2 "ip";
            grep = lib.getExe pkgs.gnugrep;
            systemd-notify = lib.getExe' pkgs.systemd "systemd-notify";
          in
          {
            Type = "notify";
            NotifyAccess = "all";
            ExecStart = "${bash} ${pkgs.writeScript "notify-interface-ready" ''
              ${ip} -ts monitor link | ${grep} --line-buffered " ${nylon-name}:" | ${grep} --line-buffered -v "DOWN" |\
              while IFS=$'\n' read -r line; do
                ${systemd-notify} --ready
                break
              done &

              ${nylon} run -c "${central-config}" -n "${node-config}";
            ''}";
          };
      };

      containers.${container-name} = lib.mkMerge [
        {
          interfaces = [ nylon-name ];
        }
        container-config
      ];
    };
in
mkNylonContainer "dns" "fd00::1" {
  privateNetwork = true;
  # hostBridge = "br-containers";
  config =
    { pkgs, ... }:
    {
      services.dnsmasq = {
        enable = true;
        settings = {
          no-resolv = true;
          bind-interface = true;
          interface = "nylon-dns";
          server = [
            "1.1.1.1@eth0"
            "8.8.8.8@eth0"
          ];
        };
      };
      environment.systemPackages = [
        pkgs.busybox
      ];
    };
}
