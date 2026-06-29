{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "gpt";
      partitions = {

        ESP = {
          size = "512M";
          type = "EF00";
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
          size = "110G";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
            mountOptions = [ "defaults" ];
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
