{ ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    networks."10-ethernet" = {
      matchConfig.Name = "eno1";
      networkConfig = {
        Address = "192.168.2.40/24";
        Gateway = "192.168.2.1";
        DNS = [
          "192.168.2.2"
          "1.1.1.1"
        ];
        DHCP = "no";
      };
    };
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  services.desktopManager.plasma6.enable = false;
  services.displayManager.sddm = {
    enable = false;
    wayland.enable = true;
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  system.stateVersion = "26.05";
}
