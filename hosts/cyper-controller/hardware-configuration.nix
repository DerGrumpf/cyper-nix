{
  config,
  lib,
  modulesPath,
  primaryUser,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = lib.mkForce {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };

    "/boot" = lib.mkForce {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    # TODO: Add External Devices as by-label with no necessity for boot
    "/storage/internal" = {
      device = "/dev/disk/by-label/STORAGE";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "nofail"
      ];
    };

    "/storage/fast" = {
      device = "/dev/disk/by-label/FAST";
      fsType = "ext4";
      options = [
        "nofail"
        "noatime"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
      ];
    };

    "/storage/backup" = {
      device = "/dev/disk/by-label/BACKUP";
      fsType = "ext4";
      options = [
        "nofail"
        "noatime"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
      ];
    };

  };

  systemd.tmpfiles.rules = [
    "d /storage 0755 ${primaryUser} users -"
    "d /storage/internal 0755 ${primaryUser} users -"
    "d /storage/fast 0755 ${primaryUser} users -"
    "d /storage/backup 0755 ${primaryUser} users -"
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
