{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
  	loader.grub = {
		enable = true;
  		device = "/dev/vda";
		};

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
  kernelModules = [ ];
  extraModulePackages = [ ];
	};

  fileSystems = {
  	"/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  	"/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };
};

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
