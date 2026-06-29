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
    secrets."network/smb_passwd" = { };
    templates.smb_credentials = {
      content = ''
        username=${primaryUser}
        password=${config.sops.placeholder."network/smb_passwd"}
      '';
    };
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=4G"
        "mode=755"
      ];
    };

    "/nix".neededForBoot = true;
    "/persist".neededForBoot = true;

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
          device = "//192.168.2.2/${share}";
          fsType = "cifs";
          options = [
            "credentials=${config.sops.templates.smb_credentials.path}"
            "iocharset=utf8"
            "_netdev"
            "nofail"
            "uid=${toString config.users.users.${primaryUser}.uid}"
            "gid=${toString config.users.users.${primaryUser}.group}"
            "file_mode=0664"
            "dir_mode=0775"
            "x-systemd.automount"
            "x-systemd.idle-timeout=60"
          ];
        };
      })
      [
        "storage-internal"
        "storage-fast"
        "storage-backup"
      ]
  );

  systemd.tmpfiles.rules = [
    "d /shares/storage-internal 0775 ${primaryUser} users -"
    "d /shares/storage-fast 0775 ${primaryUser} users -"
    "d /shares/storage-backup 0775 ${primaryUser} users -"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
