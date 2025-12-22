{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Sandisk_SSD_PLUS_1TB_2529DYD03687";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              uuid = "787e9d3f-ee33-4da3-a01d-d8c8babda2fd";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              uuid = "12cd83a1-474c-4566-8811-659aeba4a6ed";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            plainSwap = {
              size = "16G";
              uuid = "0a0f2eea-2f9f-4e1e-b712-d5120d5b743c";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            root = {
              size = "100%";
              uuid = "94825f69-fc2a-4cf9-b91d-c7a45bc1d7fa";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
