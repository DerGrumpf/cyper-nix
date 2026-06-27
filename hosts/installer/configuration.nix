{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  boot.zfs.forceImportRoot = false;

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keyFiles = [
      ../../secrets/ssh-key
    ];

    phil = {
      isNormalUser = true;
      password = "nixos";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [
        ../../secrets/ssh-key
      ];
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Name = "en*";
      networkConfig = {
        Address = "192.168.2.99/24";
        Gateway = "192.168.2.1";
        DNS = "192.168.2.2";
        DHCP = "no";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    htop
    lsscsi
    pciutils
    usbutils
    nvme-cli
  ];

  system.stateVersion = "26.05";
}
