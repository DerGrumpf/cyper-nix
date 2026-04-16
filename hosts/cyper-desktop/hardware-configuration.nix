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
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-intel"
      "v4l2loopback"
    ];
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback.out ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };

  sops = {
    secrets.smb_passwd = { };

    templates.smb_credentials = {
      content = ''
        username=${primaryUser}
        password=${config.sops.placeholder.smb_passwd}
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/storage" = {
      device = "/dev/disk/by-label/STORAGE";
      fsType = "ext4";
    };
  }
  // builtins.listToAttrs (
    map
      (share: {
        name = "/shares/${share}";
        value = {
          device = "//127.0.0.1/${share}";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates.smb_credentials.path}"
            "iocharset=utf8"
            "_netdev"
            "auto"
            "nofail"
            "x-systemd.requires=samba-smbd.service"
            "x-systemd.after=samba-smbd.service"
            "x-systemd.requires=sops-install-secrets.service"
            "x-systemd.after=sops-install-secrets.service"
          ];
        };
      })
      [
        "internal"
        "fast"
        "backup"
      ]
  );

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
