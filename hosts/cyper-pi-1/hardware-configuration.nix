{ inputs, lib, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=256M"
        "mode=755"
      ];
    };

    "/nix".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
