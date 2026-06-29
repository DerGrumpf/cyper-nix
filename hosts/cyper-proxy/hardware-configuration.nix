{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "virtio_pci"
        "virtio_scsi"
        "virtio_blk"
        "xhci_pci"
        "sr_mod"
      ];
      kernelModules = [ ];
    };
    kernel.sysctl."net.ipv4.ip_forward" = 1;
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=2G"
        "mode=755"
      ];
    };

    "/nix".neededForBoot = true;
    "/persist".neededForBoot = true;
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
