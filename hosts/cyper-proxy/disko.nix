{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/vda";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02";
        };
        ESP = {
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
            extraArgs = [
              "-n"
              "NIXBOOT"
            ];
          };
        };
        swap = {
          size = "4G";
          content = {
            type = "swap";
            extraArgs = [
              "-L"
              "NIXSWAP"
            ];
          };
        };
        nix = {
          size = "40G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            extraArgs = [
              "-L"
              "NIXSTORE"
            ];
          };
        };
        persist = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/persist";
            extraArgs = [
              "-L"
              "NIXPERSIST"
            ];
          };
        };
      };
    };
  };
}
