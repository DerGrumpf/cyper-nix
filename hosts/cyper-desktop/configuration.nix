{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../net-config.nix
    ../boot.nix
  ];

  net = {
    wgIP = "10.10.0.40/24";
    ethAddress = "192.168.2.40/24";
    ethIface = "eno1";
    ethDNS = [
      "192.168.2.2"
      "1.1.1.1"
    ];
  };

  services = {
    desktopManager.plasma6.enable = false;
    displayManager.sddm = {
      enable = false;
      wayland.enable = true;
    };
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  system.stateVersion = "26.11";
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/storage/docker";
      insecure-registries = [ "192.168.2.2:9000" ];
    };
  };
  users.users.phil.extraGroups = [ "docker" ];
  programs.fuse.userAllowOther = true;
}
